const ticketService = require('../modules/ticket/ticket.service');
const ticketRepo = require('../modules/ticket/ticket.repository');

jest.mock('../modules/ticket/ticket.repository');

describe('Ticket Workflow Rules', () => {
  const mockUser = { id: 1, name: 'Alice', department_id: 10, role: 'manager' };
  const mockCeo = { id: 2, name: 'Bob', department_id: 99, role: 'ceo' };
  const mockEmployee = { id: 3, name: 'Charlie', department_id: 10, role: 'employee' };

  beforeEach(() => {
    jest.resetAllMocks();
    ticketRepo.getUserById.mockResolvedValue({ id: 3, name: 'Charlie' });
    ticketRepo.getManagersByDepartment.mockResolvedValue([1]);
    ticketRepo.getTicketParticipants.mockResolvedValue([1, 3]);
    ticketRepo.logAction.mockResolvedValue();
    ticketRepo.createNotification.mockResolvedValue();
    ticketRepo.addComment.mockResolvedValue();
  });

  describe('Rule 1: Auto-assign to creator', () => {
    test('selfAssign=true should assign creator as assignee', async () => {
      ticketRepo.createTicket.mockImplementation(({ createdBy, assignedToId }) => {
        return Promise.resolve({
          id: 100,
          assigned_to_id: assignedToId,
          assigned_to_name: assignedToId === createdBy.id ? 'Alice' : null,
          status: assignedToId ? 'in_progress' : 'open',
        });
      });

      const result = await ticketService.createTicket(
        { title: 'Test', description: 'Test desc', assignedDeptId: 10, selfAssign: true },
        mockUser
      );

      expect(result.assigned_to_id).toBe(1);
      expect(result.status).toBe('in_progress');
    });

    test('selfAssign=false should not assign', async () => {
      ticketRepo.createTicket.mockImplementation(({ assignedToId }) => {
        return Promise.resolve({
          id: 101,
          assigned_to_id: assignedToId,
          status: assignedToId ? 'in_progress' : 'open',
        });
      });

      const result = await ticketService.createTicket(
        { title: 'Test', description: 'Test desc', assignedDeptId: 10, selfAssign: false },
        mockUser
      );

      expect(result.assigned_to_id).toBeNull();
      expect(result.status).toBe('open');
    });
  });

  describe('Rule 2: Manager self-assign options', () => {
    test('manager can pass selfAssign flag in createTicket', async () => {
      ticketRepo.createTicket.mockResolvedValue({
        id: 102, assigned_to_id: 1, assigned_to_name: 'Alice', status: 'in_progress',
      });

      const result = await ticketService.createTicket(
        { title: 'Test', description: 'Test desc', assignedDeptId: 10, selfAssign: true },
        mockUser
      );

      expect(ticketRepo.createTicket).toHaveBeenCalledWith(
        expect.objectContaining({ assignedToId: 1 })
      );
    });

    test('non-manager can also self-assign via the parameter', async () => {
      ticketRepo.createTicket.mockResolvedValue({
        id: 103, assigned_to_id: 3, assigned_to_name: 'Charlie', status: 'in_progress',
      });

      const result = await ticketService.createTicket(
        { title: 'Test', description: 'Test desc', assignedDeptId: 10, selfAssign: true },
        mockEmployee
      );

      expect(result.assigned_to_id).toBe(3);
    });
  });

  describe('Rule 3: Prevent duplicate sub-ticket per department', () => {
    test('should reject when parent ticket is open (must assign first)', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 200, title: 'Parent', status: 'open',
        immediate_child_count: 0,
        assigned_to_id: null, assigned_dept_id: 10, due_date: null,
      });

      await expect(
        ticketService.transferTicket(200, 20, mockUser, 'Sub', 'Desc')
      ).rejects.toMatchObject({
        statusCode: 400,
        message: 'Ticket must be assigned first before creating a sub-ticket.',
      });
    });

    test('should reject when department already in project tree', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 200, title: 'Parent', status: 'in_progress',
        immediate_child_count: 0,
        assigned_to_id: 1, assigned_dept_id: 10, due_date: null,
      });
      ticketRepo.isDepartmentUsedInTree.mockResolvedValue(true);

      await expect(
        ticketService.transferTicket(200, 20, mockUser, 'Sub', 'Desc')
      ).rejects.toMatchObject({
        statusCode: 400,
        message: 'This department is already part of the project lineage.',
      });
    });

    test('should allow when department not in project tree', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 200, title: 'Parent', status: 'in_progress',
        immediate_child_count: 0,
        assigned_to_id: 1, assigned_dept_id: 10, due_date: null,
      });
      ticketRepo.isDepartmentUsedInTree.mockResolvedValue(false);
      ticketRepo.createTicket.mockResolvedValue({
        id: 201, title: 'Sub', assigned_dept_id: 20, assigned_dept_name: 'Target Dept',
        status: 'open',
      });

      const result = await ticketService.transferTicket(200, 20, mockUser, 'Sub', 'Desc');
      expect(result).toBeDefined();
      expect(result.id).toBe(201);
    });
  });

  describe('Rule 4: Block completion if active children exist', () => {
    test('should reject completed status when active children exist', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 300, status: 'in_progress',
        assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(true);

      await expect(
        ticketService.updateStatus(300, 'completed', mockUser, 'Done')
      ).rejects.toMatchObject({
        statusCode: 400,
        message: 'Cannot mark as completed while sub-tickets are still active.',
      });
    });

    test('should allow completed status when no active children', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 300, status: 'in_progress',
        assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.updateStatus.mockResolvedValue({ id: 300, status: 'completed' });

      const result = await ticketService.updateStatus(300, 'completed', mockUser, 'Done');
      expect(result.status).toBe('completed');
    });

    test('should reject closed status when unfinalized sub-tickets exist', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 300, status: 'completed',
        assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.hasUnfinalizedSubTickets.mockResolvedValue(true);

      await expect(
        ticketService.updateStatus(300, 'closed', mockUser, 'Final')
      ).rejects.toMatchObject({
        statusCode: 400,
        message: expect.stringContaining('sub-tasks are still active'),
      });
    });

    test('should allow closed status when all sub-tickets finalized', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 300, status: 'completed',
        assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.hasUnfinalizedSubTickets.mockResolvedValue(false);
      ticketRepo.updateStatus.mockResolvedValue({ id: 300, status: 'closed' });

      const result = await ticketService.updateStatus(300, 'closed', mockUser, 'Final');
      expect(result.status).toBe('closed');
    });

    test('non-resolver/non-manager/non-ceo cannot mark completed', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 300, status: 'in_progress',
        assigned_to_id: null, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);

      await expect(
        ticketService.updateStatus(300, 'completed', mockEmployee, 'Done')
      ).rejects.toMatchObject({ statusCode: 403 });
    });
  });

  describe('Rule 5: Propagate completion upward', () => {
    test('should log all_children_completed on parent when child is completed', async () => {
      ticketRepo.getTicketById.mockImplementation((ticketId) => {
        if (ticketId === 401) {
          return Promise.resolve({
            id: 401, status: 'in_progress', parent_ticket_id: 402,
            assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
          });
        }
        if (ticketId === 402) {
          return Promise.resolve({
            id: 402, status: 'in_progress', parent_ticket_id: null,
            assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 99,
          });
        }
        return Promise.resolve({
          id: 400, status: 'in_progress', parent_ticket_id: 401,
          assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
        });
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.updateStatus.mockImplementation((ticketId, status) => {
        return Promise.resolve({ id: ticketId, status });
      });
      ticketRepo.getParentChain.mockResolvedValue([402]);
      ticketRepo.allChildrenCompleted.mockResolvedValue(true);

      await ticketService.updateStatus(400, 'completed', mockUser, 'Done');

      expect(ticketRepo.logAction).toHaveBeenCalledWith(
        401, 1, 'all_children_completed', null, null, expect.any(String)
      );
      expect(ticketRepo.logAction).toHaveBeenCalledWith(
        402, 1, 'all_children_completed', null, null, expect.any(String)
      );
    });

    test('should stop propagation if siblings not all done', async () => {
      ticketRepo.getTicketById.mockImplementation((ticketId) => {
        if (ticketId === 401) {
          return Promise.resolve({
            id: 401, status: 'in_progress', parent_ticket_id: 402,
            assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
          });
        }
        return Promise.resolve({
          id: 400, status: 'in_progress', parent_ticket_id: 401,
          assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
        });
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.updateStatus.mockImplementation((ticketId, status) => {
        return Promise.resolve({ id: ticketId, status });
      });
      ticketRepo.getParentChain.mockResolvedValue([402]);
      ticketRepo.allChildrenCompleted
        .mockResolvedValueOnce(false);

      await ticketService.updateStatus(400, 'completed', mockUser, 'Done');

      expect(ticketRepo.logAction).not.toHaveBeenCalledWith(
        401, 1, 'all_children_completed', null, null, expect.any(String)
      );
    });

    test('should not propagate for tickets without parent', async () => {
      ticketRepo.getTicketById.mockResolvedValue({
        id: 400, status: 'in_progress', parent_ticket_id: null,
        assigned_to_id: 1, created_by_id: 1, assigned_dept_id: 10,
      });
      ticketRepo.hasActiveChildren.mockResolvedValue(false);
      ticketRepo.updateStatus.mockImplementation((ticketId, status) => {
        return Promise.resolve({ id: ticketId, status });
      });

      await ticketService.updateStatus(400, 'completed', mockUser, 'Done');

      expect(ticketRepo.getParentChain).not.toHaveBeenCalled();
    });
  });
});
