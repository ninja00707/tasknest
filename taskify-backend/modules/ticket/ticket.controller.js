const ticketService = require('./ticket.service');

class TicketController {
  async getStats(req, res, next) {
    try {
      const stats = await ticketService.getDashboardStats(req.user);
      res.json({ success: true, data: stats });
    } catch (err) {
      next(err);
    }
  }

  async getDepartments(req, res, next) {
    try {
      const depts = await ticketService.getDepartments();
      res.json({ success: true, data: depts });
    } catch (err) {
      next(err);
    }
  }

  async getEmployees(req, res, next) {
    try {
      const employees = await ticketService.getEmployees(req.user, req.query.departmentId);
      res.json({ success: true, data: employees });
    } catch (err) {
      next(err);
    }
  }

  async getTickets(req, res, next) {
    try {
      const tickets = await ticketService.getTickets(req.user, req.query);
      res.json({ success: true, data: tickets });
    } catch (err) {
      next(err);
    }
  }

  async getTicket(req, res, next) {
    try {
      const ticket = await ticketService.getTicket(req.params.id, req.user);
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async createTicket(req, res, next) {
    try {
      const ticket = await ticketService.createTicket(req.body, req.user);
      res.status(201).json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async createSubTicket(req, res, next) {
    try {
      const ticket = await ticketService.createSubTicket(req.body, req.user);
      res.status(201).json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async updateSubDeptProgress(req, res, next) {
    try {
      const ticket = await ticketService.updateSubDeptProgress(
        req.params.id,
        req.params.deptId,
        req.body,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async assignSubDeptToEmployee(req, res, next) {
    try {
      const ticket = await ticketService.assignSubDeptToEmployee(
        req.params.id,
        req.params.deptId,
        req.body.employeeId,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async selfAssignSubDept(req, res, next) {
    try {
      const ticket = await ticketService.selfAssignSubDept(
        req.params.id,
        req.params.deptId,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async completeSubTicket(req, res, next) {
    try {
      const ticket = await ticketService.completeSubTicket(
        req.params.id,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async reopenSubDept(req, res, next) {
    try {
      const ticket = await ticketService.reopenSubDept(
        req.params.id,
        req.params.deptId,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async updateStatus(req, res, next) {
    try {
      const ticket = await ticketService.updateStatus(
        req.params.id,
        req.body.status,
        req.user,
        req.body.remark
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async selfAssign(req, res, next) {
    try {
      const ticket = await ticketService.selfAssign(req.params.id, req.user);
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async assignToEmployee(req, res, next) {
    try {
      const ticket = await ticketService.assignToEmployee(
        req.params.id,
        req.body.employeeId,
        req.user
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async transferTicket(req, res, next) {
    try {
      const { targetDeptId, title, description } = req.body;
      const ticket = await ticketService.transferTicket(
        req.params.id,
        targetDeptId,
        req.user,
        title,
        description
      );
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async reopenTicket(req, res, next) {
    try {
      const ticket = await ticketService.reopenTicket(req.params.id, req.user);
      res.json({ success: true, data: ticket });
    } catch (err) {
      next(err);
    }
  }

  async getComments(req, res, next) {
    try {
      const comments = await ticketService.getComments(req.params.id, req.user);
      res.json({ success: true, data: comments });
    } catch (err) {
      next(err);
    }
  }

  async addComment(req, res, next) {
    try {
      const comment = await ticketService.addComment(
        req.params.id,
        req.body.message,
        req.user
      );
      res.status(201).json({ success: true, data: comment });
    } catch (err) {
      next(err);
    }
  }

  async getSentTickets(req, res, next) {
    try {
      const tickets = await ticketService.getSentTickets(req.user);
      res.json({ success: true, data: tickets });
    } catch (err) {
      next(err);
    }
  }

  async getTicketLogs(req, res, next) {
    try {
      const logs = await ticketService.getTicketLogs(req.params.id, req.user);
      res.json({ success: true, data: logs });
    } catch (err) {
      next(err);
    }
  }

  async getAnalyticsByDepartment(req, res, next) {
    try {
      const analytics = await ticketService.getAnalyticsByDepartment();
      res.json({ success: true, data: analytics });
    } catch (err) {
      next(err);
    }
  }

  async getDepartmentAnalytics(req, res, next) {
    try {
      const stats = await ticketService.getDepartmentAnalytics(req.params.departmentId);
      res.json({ success: true, data: stats });
    } catch (err) {
      next(err);
    }
  }

  async getOrganizationAnalytics(req, res, next) {
    try {
      const analytics = await ticketService.getOrganizationAnalytics();
      res.json({ success: true, data: analytics });
    } catch (err) {
      next(err);
    }
  }

  async updateTicket(req, res, next) {
    try {
      const updated = await ticketService.updateTicket(
        req.params.id,
        req.user,
        req.body
      );
      res.json({ success: true, data: updated });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new TicketController();
