const ticketService = require('./ticket.service');

exports.createTicket = async (req, res) => {
  try {
    const { title, description, target_department_id, company_id } = req.body;
    
    // In a real app, req.user is set by auth middleware.
    // For now, we assume the user object is sent in req.user or req.body for testing.
    // If you add JWT middleware, it will be req.user.id
    const creator = req.user || req.body.user; 
    
    if (!creator || !creator.id) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const ticket = await ticketService.createTicket({
      title,
      description,
      creator_id: creator.id,
      target_department_id,
      company_id
    });

    return res.status(201).json({
      success: true,
      message: 'Ticket created successfully',
      data: ticket
    });
  } catch (error) {
    console.error('Create Ticket Error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Error creating ticket'
    });
  }
};

exports.getTickets = async (req, res) => {
  try {
    const user = req.user || req.body.user;
    if (!user || !user.id || !user.role || !user.department_id || !user.company_id) {
      return res.status(401).json({ success: false, message: 'Unauthorized or missing user context' });
    }

    const tickets = await ticketService.getTickets(user);

    return res.status(200).json({
      success: true,
      data: tickets
    });
  } catch (error) {
    console.error('Get Tickets Error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Error fetching tickets'
    });
  }
};

exports.assignTicket = async (req, res) => {
  try {
    const user = req.user || req.body.user;
    const ticketId = req.params.id;
    const { assignee_id } = req.body;

    if (!user) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const ticket = await ticketService.assignTicket(ticketId, user, assignee_id);

    return res.status(200).json({
      success: true,
      message: 'Ticket assigned successfully',
      data: ticket
    });
  } catch (error) {
    console.error('Assign Ticket Error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Error assigning ticket'
    });
  }
};

exports.closeTicket = async (req, res) => {
  try {
    const user = req.user || req.body.user;
    const ticketId = req.params.id;

    if (!user) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const ticket = await ticketService.closeTicket(ticketId, user);

    return res.status(200).json({
      success: true,
      message: 'Ticket closed successfully',
      data: ticket
    });
  } catch (error) {
    console.error('Close Ticket Error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Error closing ticket'
    });
  }
};

exports.reopenTicket = async (req, res) => {
  try {
    const user = req.user || req.body.user;
    const ticketId = req.params.id;

    if (!user) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const ticket = await ticketService.reopenTicket(ticketId, user);

    return res.status(200).json({
      success: true,
      message: 'Ticket reopened successfully',
      data: ticket
    });
  } catch (error) {
    console.error('Reopen Ticket Error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Error reopening ticket'
    });
  }
};
