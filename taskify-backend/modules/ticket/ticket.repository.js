const pool = require('../../database/db');

class TicketRepository {
  async getTicketDetails(ticketId) {
    const result = await pool.query(`
      WITH RECURSIVE root_finder AS (
        -- Find the absolute root of this ticket lineage
        SELECT id, parent_ticket_id FROM tickets WHERE id = $1
        UNION ALL
        SELECT t.id, t.parent_ticket_id FROM tickets t
        JOIN root_finder rf ON t.id = rf.parent_ticket_id
      ),
      the_root AS (
        SELECT id FROM root_finder WHERE parent_ticket_id IS NULL LIMIT 1
      ),
      full_lineage AS (
        -- Get every single ticket in this root's entire tree
        SELECT id, parent_ticket_id, created_by_dept, assigned_dept_id, created_at FROM tickets WHERE id = (SELECT id FROM the_root)
        UNION ALL
        SELECT t.id, t.parent_ticket_id, t.created_by_dept, t.assigned_dept_id, t.created_at FROM tickets t
        JOIN full_lineage fl ON t.parent_ticket_id = fl.id
      ),
      journey_steps AS (
        -- Capture every unique department that has ever touched this project
        SELECT DISTINCT ON (dept_id)
          dept_id as id, code, name, first_seen
        FROM (
          SELECT created_by_dept as dept_id, created_at as first_seen FROM full_lineage
          UNION ALL
          SELECT assigned_dept_id as dept_id, created_at as first_seen FROM full_lineage
        ) raw_steps
        JOIN departments d ON d.id = dept_id
        ORDER BY dept_id, first_seen ASC
      )
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.ticket_number,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.closed_at, t.reopened_at, t.reopen_count,
        t.is_sub_ticket, t.overall_progress,
        t.parent_ticket_id, t.ticket_type,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,
        reporter_assignee.name AS assigned_to_reports_to_name,
        reporter_creator.name AS created_by_reports_to_name,

        ll.action      AS last_action,
        ll.created_at  AS last_updated_at,
        ll.acted_by_name AS last_acted_by_name,

        tf.code AS transferred_from_code,
        pt.title AS parent_ticket_title,
        pt.ticket_number AS parent_ticket_number,
        t.parent_ticket_id, t.ticket_type,

        -- Fetch immediate children count
        (SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.id) as immediate_child_count,
        
        -- Check if there are any unfinalized (not closed) descendants
        EXISTS (
          WITH RECURSIVE descendants AS (
            SELECT id, status FROM tickets WHERE parent_ticket_id = t.id
            UNION ALL
            SELECT child.id, child.status FROM tickets child
            JOIN descendants d ON child.parent_ticket_id = d.id
          )
          SELECT 1 FROM descendants WHERE status != 'closed'
        ) as has_active_children,

        -- Fetch recursive department journey (Global Project Journey)
        (
          SELECT json_agg(js) FROM (
            SELECT id, code, name,
            CASE 
              WHEN id = (SELECT created_by_dept FROM tickets WHERE id = (SELECT id FROM the_root)) THEN 'ORIGIN'
              WHEN id = t.assigned_dept_id THEN 'CURRENT'
              ELSE 'LINK'
            END as role
            FROM journey_steps 
            ORDER BY first_seen ASC
          ) js
        ) AS dept_journey

      FROM tickets t
      LEFT JOIN users creator  ON creator.id = t.created_by_id
      LEFT JOIN departments cd ON cd.id = t.created_by_dept
      LEFT JOIN departments ad ON ad.id = t.assigned_dept_id
      LEFT JOIN users assignee ON assignee.id = t.assigned_to_id
      LEFT JOIN users reporter_assignee ON reporter_assignee.id = assignee.reports_to
      LEFT JOIN users reporter_creator ON reporter_creator.id = creator.reports_to
      LEFT JOIN departments tf ON tf.id = t.transferred_from
      LEFT JOIN tickets pt     ON pt.id = t.parent_ticket_id
      LEFT JOIN LATERAL (
        SELECT tl.action, tl.created_at, u.name as acted_by_name
        FROM ticket_logs tl
        JOIN users u ON u.id = tl.acted_by_id
        WHERE tl.ticket_id = t.id
        ORDER BY tl.created_at DESC
        LIMIT 1
      ) ll ON TRUE
      WHERE t.id = $1
    `, [ticketId]);

    let ticket = result.rows[0] || null;
    if (ticket) {
      // Fetch ALL descendants recursively for this ticket project
      const childrenResult = await pool.query(`
        WITH RECURSIVE descendants AS (
          -- Base: Immediate children
          SELECT id FROM tickets WHERE parent_ticket_id = $1
          UNION ALL
          -- Recursive: Children of children
          SELECT t.id FROM tickets t
          JOIN descendants d ON t.parent_ticket_id = d.id
        )
        SELECT t.id, t.title, t.status, t.assigned_dept_id, t.assigned_to_id, t.created_by_id,
               t.ticket_number, t.created_at, t.created_by_dept, t.priority,
               d.code as dept_code, d.name as dept_name, u.name as assignee_name,
               creator.name as created_by_name, cd.code as created_by_dept_code, cd.name as created_by_dept_name
        FROM tickets t
        JOIN descendants d_tree ON t.id = d_tree.id
        LEFT JOIN departments d ON d.id = t.assigned_dept_id
        LEFT JOIN users u ON u.id = t.assigned_to_id
        LEFT JOIN users creator ON creator.id = t.created_by_id
        LEFT JOIN departments cd ON cd.id = t.created_by_dept
      `, [ticketId]);
      ticket.children = childrenResult.rows;
    }

    return ticket;
  }

  async isDepartmentUsedInTree(ticketId, departmentId) {
    const result = await pool.query(`
      WITH RECURSIVE root_finder AS (
        -- Find the absolute root of this ticket lineage
        SELECT id, parent_ticket_id FROM tickets WHERE id = $1
        UNION ALL
        SELECT t.id, t.parent_ticket_id FROM tickets t
        JOIN root_finder rf ON t.id = rf.parent_ticket_id
      ),
      the_root AS (
        SELECT id FROM root_finder WHERE parent_ticket_id IS NULL LIMIT 1
      ),
      full_tree AS (
        -- Get every single ticket in this root's entire tree
        SELECT id, assigned_dept_id FROM tickets WHERE id = (SELECT id FROM the_root)
        UNION ALL
        SELECT t.id, t.assigned_dept_id FROM tickets t
        JOIN full_tree ft ON t.parent_ticket_id = ft.id
      )
      SELECT 1 FROM (
        SELECT assigned_dept_id as dept_id FROM full_tree
        UNION
        SELECT department_id as dept_id FROM sub_ticket_departments WHERE ticket_id IN (SELECT id FROM full_tree)
      ) combined
      WHERE dept_id = $2
      LIMIT 1
    `, [ticketId, departmentId]);
    return result.rows.length > 0;
  }

  async hasUnfinalizedSubTickets(ticketId) {
    const result = await pool.query(`
      WITH RECURSIVE descendants AS (
        SELECT id, status FROM tickets WHERE parent_ticket_id = $1
        UNION ALL
        SELECT t.id, t.status FROM tickets t
        JOIN descendants d ON t.parent_ticket_id = d.id
      )
      SELECT 1 FROM descendants
      WHERE status != 'closed'
      LIMIT 1
    `, [ticketId]);
    return result.rows.length > 0;
  }

  // ── Get tickets visible to this user based on role ────────────────────────
  async getVisibleTickets(user, filters = {}) {
    const { status, priority, page = 1, limit = 15, scope } = filters;
    const offset = (Number(page) - 1) * Number(limit);
    const params = [];
    let whereClause = 'WHERE t.parent_ticket_id IS NULL'; // Only show top-level tickets

    if (scope === 'team') {
      // "My Team" — tickets where creator or assignee is a DIRECT report
      params.push(user.id);
      const userIdParam = `$${params.length}`;
      whereClause += ` AND (
        t.created_by_id IN (SELECT id FROM users WHERE reports_to = ${userIdParam})
        OR t.assigned_to_id IN (SELECT id FROM users WHERE reports_to = ${userIdParam})
      )`;
    } else if (user.role === 'ceo') {
      // CEO sees everything top-level
    } else {
      params.push(user.department_id);
      const deptParam = `$${params.length}`;
      whereClause += ` AND (
        t.assigned_dept_id = ${deptParam}
        OR t.created_by_dept = ${deptParam}
        OR EXISTS (
          WITH RECURSIVE child_search AS (
            SELECT id, parent_ticket_id, assigned_dept_id, created_by_dept FROM tickets WHERE parent_ticket_id = t.id
            UNION ALL
            SELECT child.id, child.parent_ticket_id, child.assigned_dept_id, child.created_by_dept FROM tickets child
            JOIN child_search cs ON child.parent_ticket_id = cs.id
          )
          SELECT 1 FROM child_search 
          WHERE assigned_dept_id = ${deptParam} OR created_by_dept = ${deptParam}
        )
      )`;
    }

    // Company-level isolation (non-CEO users only see their company's depts + shared depts)
    // Also checks sub-tickets recursively (for cross-department tickets to shared depts)
    if (user.role !== 'ceo') {
      params.push(user.company_id);
      const companyParam = `$${params.length}`;
      whereClause += ` AND EXISTS (
        SELECT 1 FROM departments d
        WHERE (d.company_id = ${companyParam} OR d.is_shared = TRUE)
        AND (
          d.id IN (t.assigned_dept_id, t.created_by_dept)
          OR EXISTS (
            WITH RECURSIVE child_search AS (
              SELECT id, assigned_dept_id, created_by_dept FROM tickets WHERE parent_ticket_id = t.id
              UNION ALL
              SELECT child.id, child.assigned_dept_id, child.created_by_dept FROM tickets child
              JOIN child_search cs ON child.parent_ticket_id = cs.id
            )
            SELECT 1 FROM child_search WHERE assigned_dept_id = d.id OR created_by_dept = d.id
          )
        )
      )`;
    }

    if (status) {
      params.push(status);
      whereClause += ` AND t.status = $${params.length}`;
    }
    if (priority) {
      params.push(priority);
      whereClause += ` AND t.priority = $${params.length}`;
    }

    params.push(Number(limit), offset);

    const query = `
      WITH RECURSIVE root_finder AS (
        -- For each ticket in the list, find its absolute root
        SELECT id as leaf_id, id, parent_ticket_id FROM tickets t
        UNION ALL
        SELECT rf.leaf_id, t.id, t.parent_ticket_id FROM tickets t
        JOIN root_finder rf ON t.id = rf.parent_ticket_id
      ),
      the_roots AS (
        SELECT leaf_id, id as root_id FROM root_finder WHERE parent_ticket_id IS NULL
      ),
      tree_lineage AS (
        -- Get every single ticket in every relevant root's tree
        SELECT tr.leaf_id, t.id, t.parent_ticket_id, t.created_by_dept, t.assigned_dept_id, t.created_at 
        FROM tickets t
        JOIN the_roots tr ON t.id = tr.root_id
        UNION ALL
        SELECT tl.leaf_id, t.id, t.parent_ticket_id, t.created_by_dept, t.assigned_dept_id, t.created_at 
        FROM tickets t
        JOIN tree_lineage tl ON t.parent_ticket_id = tl.id
      ),
      journey_agg AS (
        -- Aggregate unique departments per project tree
        SELECT leaf_id, json_agg(js ORDER BY first_seen ASC) as journey FROM (
          SELECT DISTINCT ON (tl.leaf_id, d.id)
            tl.leaf_id, d.id as id, d.code, d.name, MIN(tl.created_at) as first_seen,
            CASE 
              WHEN d.id = (SELECT created_by_dept FROM tickets WHERE id = (SELECT root_id FROM the_roots WHERE leaf_id = tl.leaf_id)) THEN 'ORIGIN'
              ELSE 'LINK'
            END as role
          FROM tree_lineage tl
          JOIN departments d ON (d.id = tl.created_by_dept OR d.id = tl.assigned_dept_id)
          GROUP BY tl.leaf_id, d.id, d.code, d.name
        ) js
        GROUP BY leaf_id
      )
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.ticket_number,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at,
        t.is_sub_ticket, t.overall_progress,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,

        ll.action      AS last_action,
        ll.created_at  AS last_updated_at,
        ll.acted_by_name AS last_acted_by_name,

        tf.code AS transferred_from_code,
        pt.title AS parent_ticket_title,
        pt.ticket_number AS parent_ticket_number,
        t.parent_ticket_id, t.ticket_type,

        -- Fetch children count
        (SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.id) as immediate_child_count,

        -- Check if there are any unfinalized (not closed) descendants
        EXISTS (
          WITH RECURSIVE descendants AS (
            SELECT id, status FROM tickets WHERE parent_ticket_id = t.id
            UNION ALL
            SELECT child.id, child.status FROM tickets child
            JOIN descendants d ON child.parent_ticket_id = d.id
          )
          SELECT 1 FROM descendants WHERE status != 'closed'
        ) as has_active_children,

        -- Fetch Global Project Journey
        COALESCE(ja.journey, '[]'::json) as dept_journey

      FROM tickets t
      LEFT JOIN users       creator  ON creator.id  = t.created_by_id
      LEFT JOIN departments cd       ON cd.id        = t.created_by_dept
      LEFT JOIN departments ad       ON ad.id        = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id  = t.assigned_to_id
      LEFT JOIN users  reporter_assignee ON reporter_assignee.id = assignee.reports_to
      LEFT JOIN users  reporter_creator ON reporter_creator.id = creator.reports_to
      LEFT JOIN departments tf  ON tf.id        = t.transferred_from
      LEFT JOIN tickets pt     ON pt.id        = t.parent_ticket_id
      LEFT JOIN journey_agg ja ON ja.leaf_id   = t.id
      LEFT JOIN LATERAL (
        SELECT tl.action, tl.created_at, u.name as acted_by_name
        FROM ticket_logs tl
        JOIN users u ON u.id = tl.acted_by_id
        WHERE tl.ticket_id = t.id
        ORDER BY tl.created_at DESC
        LIMIT 1
      ) ll ON TRUE
      ${whereClause}
      ORDER BY
        ll.created_at DESC NULLS LAST,
        CASE t.priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `;

    const countResult = await pool.query(`
      SELECT COUNT(*)::int AS total FROM tickets t
      ${whereClause}
    `, params.slice(0, params.length - 2));

    const total = countResult.rows[0].total;

    const result = await pool.query(query, params);
    const tickets = await this.enrichTicketsWithChildData(result.rows);
    return { tickets, total };
  }

  async enrichTicketsWithChildData(tickets) {
    if (tickets.length === 0) return tickets;
    const ids = tickets.map(t => t.id);

    // Fetch ALL descendants for these master tickets recursively
    const children = await pool.query(`
      WITH RECURSIVE descendants AS (
        -- Base: Immediate children of the master tickets
        SELECT id, parent_ticket_id, id as top_level_parent_id 
        FROM tickets 
        WHERE parent_ticket_id = ANY($1::int[])
        
        UNION ALL
        
        -- Recursive: Children of the children
        SELECT t.id, t.parent_ticket_id, d.top_level_parent_id
        FROM tickets t
        JOIN descendants d ON t.parent_ticket_id = d.id
      )
      SELECT t.id, t.parent_ticket_id, t.title, t.status, t.assigned_dept_id, t.assigned_to_id, t.created_by_id,
             d_info.code as dept_code, u.name as assignee_name,
             (SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.id) as immediate_child_count,
             EXISTS (
               WITH RECURSIVE sub_descendants AS (
                 SELECT id, status FROM tickets WHERE parent_ticket_id = t.id
                 UNION ALL
                 SELECT child.id, child.status FROM tickets child
                 JOIN sub_descendants sd ON child.parent_ticket_id = sd.id
               )
               SELECT 1 FROM sub_descendants WHERE status != 'closed'
             ) as has_active_children,
             -- We need to know which master ticket this descendant ultimately belongs to
             (
               WITH RECURSIVE root_finder AS (
                 SELECT id, parent_ticket_id FROM tickets WHERE id = t.id
                 UNION ALL
                 SELECT t2.id, t2.parent_ticket_id FROM tickets t2
                 JOIN root_finder rf ON t2.id = rf.parent_ticket_id
               )
               SELECT id FROM root_finder WHERE parent_ticket_id IS NULL LIMIT 1
             ) as master_id
      FROM tickets t
      JOIN descendants desc_tree ON t.id = desc_tree.id
      LEFT JOIN departments d_info ON d_info.id = t.assigned_dept_id
      LEFT JOIN users u ON u.id = t.assigned_to_id
    `, [ids]);

    const byMaster = {};
    for (const child of children.rows) {
      if (!byMaster[child.master_id]) byMaster[child.master_id] = [];
      byMaster[child.master_id].push(child);
    }

    return tickets.map(t => ({
      ...t,
      children: byMaster[t.id] || []
    }));
  }

  // ── Get tickets assigned to a specific user ──────────────────────────────
  async getMyTickets(userId, filters = {}) {
    const { status, priority, page = 1, limit = 20 } = filters;
    const offset = (Number(page) - 1) * Number(limit);
    const params = [userId];

    // Show top-level tickets where the user is assigned to the ticket itself OR any of its nested children
    let whereClause = `WHERE t.parent_ticket_id IS NULL AND (
      t.assigned_to_id = $1 
      OR EXISTS (
        WITH RECURSIVE child_search AS (
          SELECT id, parent_ticket_id, assigned_to_id FROM tickets WHERE parent_ticket_id = t.id
          UNION ALL
          SELECT child.id, child.parent_ticket_id, child.assigned_to_id FROM tickets child
          JOIN child_search cs ON child.parent_ticket_id = cs.id
        )
        SELECT 1 FROM child_search WHERE assigned_to_id = $1
      )
    )`;

    if (status) {
      params.push(status);
      whereClause += ` AND t.status = $${params.length}`;
    }
    if (priority) {
      params.push(priority);
      whereClause += ` AND t.priority = $${params.length}`;
    }

    params.push(Number(limit), offset);

    const query = `
      WITH RECURSIVE root_finder AS (
        -- For each ticket in the list, find its absolute root
        SELECT id as leaf_id, id, parent_ticket_id FROM tickets t
        UNION ALL
        SELECT rf.leaf_id, t.id, t.parent_ticket_id FROM tickets t
        JOIN root_finder rf ON t.id = rf.parent_ticket_id
      ),
      the_roots AS (
        SELECT leaf_id, id as root_id FROM root_finder WHERE parent_ticket_id IS NULL
      ),
      tree_lineage AS (
        -- Get every single ticket in every relevant root's tree
        SELECT tr.leaf_id, t.id, t.parent_ticket_id, t.created_by_dept, t.assigned_dept_id, t.created_at 
        FROM tickets t
        JOIN the_roots tr ON t.id = tr.root_id
        UNION ALL
        SELECT tl.leaf_id, t.id, t.parent_ticket_id, t.created_by_dept, t.assigned_dept_id, t.created_at 
        FROM tickets t
        JOIN tree_lineage tl ON t.parent_ticket_id = tl.id
      ),
      journey_agg AS (
        -- Aggregate unique departments per project tree
        SELECT leaf_id, json_agg(js ORDER BY first_seen ASC) as journey FROM (
          SELECT DISTINCT ON (tl.leaf_id, d.id)
            tl.leaf_id, d.id as id, d.code, d.name, MIN(tl.created_at) as first_seen,
            CASE 
              WHEN d.id = (SELECT created_by_dept FROM tickets WHERE id = (SELECT root_id FROM the_roots WHERE leaf_id = tl.leaf_id)) THEN 'ORIGIN'
              ELSE 'LINK'
            END as role
          FROM tree_lineage tl
          JOIN departments d ON (d.id = tl.created_by_dept OR d.id = tl.assigned_dept_id)
          GROUP BY tl.leaf_id, d.id, d.code, d.name
        ) js
        GROUP BY leaf_id
      )
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.ticket_number,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at,
        t.is_sub_ticket, t.overall_progress,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.name      AS created_by_dept_name,
        ad.name      AS assigned_dept_name,
        assignee.name AS assigned_to_name,
        reporter_assignee.name AS assigned_to_reports_to_name,
        reporter_creator.name AS created_by_reports_to_name,
        tf.code AS transferred_from_code,
        pt.title AS parent_ticket_title,
        pt.ticket_number AS parent_ticket_number,
        t.parent_ticket_id, t.ticket_type,

        -- Fetch children count
        (SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.id) as immediate_child_count,

        -- Fetch Global Project Journey
        COALESCE(ja.journey, '[]'::json) as dept_journey,

        ll.action      AS last_action,
        ll.created_at  AS last_updated_at,
        ll.acted_by_name AS last_acted_by_name
      FROM tickets t
      LEFT JOIN users       creator  ON creator.id  = t.created_by_id
      LEFT JOIN departments cd       ON cd.id        = t.created_by_dept
      LEFT JOIN departments ad       ON ad.id        = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id  = t.assigned_to_id
      LEFT JOIN users  reporter_assignee ON reporter_assignee.id = assignee.reports_to
      LEFT JOIN users  reporter_creator ON reporter_creator.id = creator.reports_to
      LEFT JOIN departments tf  ON tf.id        = t.transferred_from
      LEFT JOIN tickets pt     ON pt.id        = t.parent_ticket_id
      LEFT JOIN journey_agg ja ON ja.leaf_id   = t.id
      LEFT JOIN LATERAL (
        SELECT tl.action, tl.created_at, u.name as acted_by_name
        FROM ticket_logs tl
        JOIN users u ON u.id = tl.acted_by_id
        WHERE tl.ticket_id = t.id
        ORDER BY tl.created_at DESC
        LIMIT 1
      ) ll ON TRUE
      ${whereClause}
      ORDER BY t.created_at DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `;

    const result = await pool.query(query, params);
    return await this.enrichTicketsWithChildData(result.rows);
  }

  // ── Dashboard stats for a user ────────────────────────────────────────────
  async getDashboardStats(user) {
    let whereClause = '';
    const params = [];

    if (user.role !== 'ceo') {
      params.push(user.department_id);
      whereClause = `WHERE (
        assigned_dept_id = $1
        OR created_by_dept = $1
        OR (
          is_sub_ticket = TRUE AND EXISTS (
            SELECT 1 FROM sub_ticket_departments std
            WHERE std.ticket_id = tickets.id AND std.department_id = $1
          )
        )
      )`;
    }

    // Company-level isolation
    if (user.role !== 'ceo') {
      params.push(user.company_id);
      const idx = params.length;
      whereClause += `${params.length === 2 ? '' : ' WHERE '} AND EXISTS (
        SELECT 1 FROM departments d
        WHERE (d.company_id = $${idx} OR d.is_shared = TRUE)
        AND (
          d.id IN (tickets.assigned_dept_id, tickets.created_by_dept)
          OR EXISTS (
            WITH RECURSIVE child_search AS (
              SELECT id, assigned_dept_id, created_by_dept FROM tickets WHERE parent_ticket_id = tickets.id
              UNION ALL
              SELECT child.id, child.assigned_dept_id, child.created_by_dept FROM tickets child
              JOIN child_search cs ON child.parent_ticket_id = cs.id
            )
            SELECT 1 FROM child_search WHERE assigned_dept_id = d.id OR created_by_dept = d.id
          )
        )
      )`;
    }

    const result = await pool.query(`
      SELECT
        COUNT(*)                                          AS total,
        COUNT(*) FILTER (WHERE status = 'open')          AS open,
        COUNT(*) FILTER (WHERE status = 'in_progress')   AS in_progress,
        COUNT(*) FILTER (WHERE status = 'completed')     AS completed,
        COUNT(*) FILTER (WHERE status = 'closed')        AS closed,
        COUNT(*) FILTER (WHERE priority = 'urgent')      AS urgent,
        COUNT(*) FILTER (WHERE priority = 'high')        AS high_priority,
        COUNT(*) FILTER (WHERE due_date < NOW() AND status NOT IN ('completed','closed')) AS overdue
      FROM tickets ${whereClause}
    `, params);

    return result.rows[0];
  }

  // ── Get single ticket (with permission check) ─────────────────────────────
  async getTicketById(ticketId, user, isSystemUpdate = false) {
    let ticket = await this.getTicketDetails(ticketId);

    if (!ticket) return null;

    ticket = await this.enrichTicketWithSubData(ticket);

    // ── Fetch comments ─────────────────────────────────────────────
    const commentsRes = await pool.query(`
      SELECT tc.*, u.name AS user_name, d.code AS dept_code
      FROM ticket_comments tc
      JOIN users u       ON u.id = tc.user_id
      JOIN departments d ON d.id = u.department_id
      WHERE tc.ticket_id = $1
      ORDER BY tc.created_at DESC
    `, [ticketId]);
    ticket.comments = commentsRes.rows;

    if (user.role === 'ceo' || isSystemUpdate) {
      return ticket;
    }

    const isCreatorDept = Number(ticket.created_by_dept) === Number(user.department_id);
    const isAssignedDept = Number(ticket.assigned_dept_id) === Number(user.department_id);
    const isTransferrer = Number(ticket.transferred_from) === Number(user.department_id);
    const isResolver = ticket.assigned_to_id === user.id;

    // Company-level check: ticket's department must belong to user's company or be shared
    // Also checks sub-tickets recursively (for cross-department tickets to shared depts)
    const companyCheck = await pool.query(
      `SELECT 1 FROM departments d
       WHERE (d.company_id = $3 OR d.is_shared = TRUE)
       AND (
         d.id IN ($1, $2)
         OR EXISTS (
           WITH RECURSIVE child_search AS (
             SELECT id, assigned_dept_id, created_by_dept FROM tickets WHERE parent_ticket_id = $4
             UNION ALL
             SELECT child.id, child.assigned_dept_id, child.created_by_dept FROM tickets child
             JOIN child_search cs ON child.parent_ticket_id = cs.id
           )
           SELECT 1 FROM child_search WHERE assigned_dept_id = d.id OR created_by_dept = d.id
         )
       )
       LIMIT 1`,
      [ticket.assigned_dept_id, ticket.created_by_dept, user.company_id, ticket.id]
    );
    const sameCompany = companyCheck.rows.length > 0;

    let isSubTicketDept = false;
    if (ticket.is_sub_ticket) {
      const subDeptCheck = await pool.query(
        `SELECT 1 FROM sub_ticket_departments WHERE ticket_id = $1 AND department_id = $2 LIMIT 1`,
        [ticketId, user.department_id]
      );
      isSubTicketDept = subDeptCheck.rows.length > 0;
    }

    if (!sameCompany) {
      return { forbidden: true };
    }

    if (!isAssignedDept && !isCreatorDept && !isTransferrer && !isResolver && !isSubTicketDept) {
      // Check if user's department is anywhere in the project tree's journey
      // (covers: any descendant's creator/assignee dept, transferred depts, etc.)
      if (Array.isArray(ticket.dept_journey) && ticket.dept_journey.some(
        step => Number(step.id) === Number(user.department_id)
      )) {
        return ticket;
      }
      // Check if ticket's creator or assignee is a direct report of the user
      // (supports the "My Team" view — manager can see reports' tickets)
      if (ticket.created_by_id) {
        const reportsToMe = await pool.query(
          `SELECT 1 FROM users WHERE id = $1 AND reports_to = $2 LIMIT 1`,
          [ticket.created_by_id, user.id]
        );
        if (reportsToMe.rows.length > 0) return ticket;
      }
      if (ticket.assigned_to_id && Number(ticket.assigned_to_id) !== Number(ticket.created_by_id)) {
        const reportsToMe = await pool.query(
          `SELECT 1 FROM users WHERE id = $1 AND reports_to = $2 LIMIT 1`,
          [ticket.assigned_to_id, user.id]
        );
        if (reportsToMe.rows.length > 0) return ticket;
      }
      // For sub-tickets, also walk up the parent chain
      if (ticket.parent_ticket_id) {
        let parentId = ticket.parent_ticket_id;
        while (parentId) {
          const parent = await this.getTicketDetails(parentId);
          if (!parent) break;
          const hasParentAccess =
            Number(parent.created_by_dept) === Number(user.department_id) ||
            Number(parent.assigned_dept_id) === Number(user.department_id) ||
            Number(parent.transferred_from) === Number(user.department_id) ||
            parent.assigned_to_id === user.id;
          if (hasParentAccess) return ticket;
          parentId = parent.parent_ticket_id;
        }
      }
      return { forbidden: true };
    }

    return ticket;
  }

  // ── Create ticket ─────────────────────────────────────────────────────────
  async createTicket({ title, description, priority, assignedDeptId, dueDate, createdBy, assignedToId, parentTicketId = null, ticketType = 'standard' }) {
    // Strict check for assignedToId to set correct status
    const status = (assignedToId != null) ? 'in_progress' : 'open';
    const isSubTicket = parentTicketId != null;

    // Generate ticket number
    let ticketNumber;
    if (parentTicketId) {
      // Sub-ticket: inherit parent number + append SUB counter
      const parentRes = await pool.query(`SELECT ticket_number FROM tickets WHERE id = $1`, [parentTicketId]);
      const parentNumber = parentRes.rows[0]?.ticket_number;
      if (parentNumber) {
        const subCountRes = await pool.query(`SELECT COUNT(*) AS cnt FROM tickets WHERE parent_ticket_id = $1`, [parentTicketId]);
        const subSerial = (subCountRes.rows[0]?.cnt || 0) + 1;
        ticketNumber = `${parentNumber}-SUB-${String(subSerial).padStart(3, '0')}`;
      }
    }
    if (!ticketNumber) {
      // Master ticket: use sequence
      const seqRes = await pool.query(`SELECT NEXTVAL('ticket_number_seq') AS val`);
      const seqVal = seqRes.rows[0].val;
      ticketNumber = `UMP-TKQ-${String(seqVal).padStart(3, '0')}`;
    }

    const result = await pool.query(`
      INSERT INTO tickets
        (title, description, priority, assigned_dept_id, due_date, created_by_id, created_by_dept, assigned_to_id, status, parent_ticket_id, ticket_type, is_sub_ticket, ticket_number)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING id
    `, [title, description, priority, assignedDeptId, dueDate || null, createdBy.id, createdBy.department_id, assignedToId || null, status, parentTicketId, ticketType, isSubTicket, ticketNumber]);

    return await this.getTicketDetails(result.rows[0].id);
  }

  // ── Update ticket status ─────────────────────────────────────────────────
  async updateStatus(ticketId, status, user) {
    console.log(`[TicketRepository] Executing updateStatus for ticketId: ${ticketId}, status: ${status}, userId: ${user.id}`);
    await pool.query(`
      UPDATE tickets SET status = $1::VARCHAR,
        closed_by_id = CASE WHEN $1::VARCHAR IN ('closed', 'completed') THEN $2 ELSE closed_by_id END,
        closed_at    = CASE WHEN $1::VARCHAR IN ('closed', 'completed') THEN NOW() ELSE closed_at END
      WHERE id = $3
    `, [status, user.id, ticketId]);

    return await this.getTicketDetails(ticketId);
  }

  // ── Update generic ticket fields ──────────────────────────────────────────
  async updateTicketField(ticketId, userId, fields) {
    const allowed = ['title', 'description', 'priority', 'due_date', 'dueDate'];
    const sets = [];
    const params = [];
    let idx = 1;

    for (const [key, value] of Object.entries(fields)) {
      if (allowed.includes(key)) {
        // Map camelCase keys to snake_case columns
        const col = key === 'dueDate' || key === 'due_date' ? 'due_date' : key;
        sets.push(`${col} = $${idx++}`);
        params.push(value);
      }
    }

    if (sets.length === 0) return null;

    params.push(ticketId);
    await pool.query(`
      UPDATE tickets SET ${sets.join(', ')}, updated_at = NOW()
      WHERE id = $${idx}
    `, params);

    return await this.getTicketDetails(ticketId);
  }

  // ── Self-assign open ticket (employee only) ───────────────────────────────
  async selfAssign(ticketId, userId) {
    const result = await pool.query(`
      UPDATE tickets
      SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2 AND status = 'open' AND assigned_to_id IS NULL
      RETURNING id
    `, [userId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Manager assigns ticket to employee ───────────────────────────────────
  async assignToEmployee(ticketId, employeeId, managerId) {
    // Verify employee is in same dept as manager
    const empCheck = await pool.query(
      `SELECT u.id FROM users u WHERE u.id = $1 AND u.department_id = (
         SELECT u2.department_id FROM users u2 WHERE u2.id = $2
       )`,
      [employeeId, managerId]
    );

    if (empCheck.rows.length === 0) {
      throw new Error('Employee not in same department');
    }

    const result = await pool.query(`
      UPDATE tickets
      SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2
      RETURNING id
    `, [employeeId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Transfer ticket to another department ─────────────────────────────────
  async transferTicket(ticketId, targetDeptId, user) {
    const result = await pool.query(`
      UPDATE tickets
      SET assigned_dept_id   = $1,
          transferred_from   = assigned_dept_id,
          transferred_at     = NOW(),
          assigned_to_id     = NULL,
          status             = 'open'
      WHERE id = $2
      RETURNING id
    `, [targetDeptId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Reopen ticket (creator, within 48h, once only) ────────────────────────
  async reopenTicket(ticketId, userId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const ticket = await client.query(
        `SELECT * FROM tickets WHERE id = $1`, [ticketId]
      );
      if (ticket.rows.length === 0) throw new Error('Ticket not found');

      const t = ticket.rows[0];

      if (t.created_by_id !== userId) throw new Error('Only the creator can reopen this ticket');
      if (t.reopen_count >= 1) throw new Error('Ticket can only be reopened once');
      if (t.status !== 'closed' && t.status !== 'completed') throw new Error('Only closed/completed tickets can be reopened');

      const resolutionTime = t.closed_at || t.updated_at;
      const hoursSinceClosed = (Date.now() - new Date(resolutionTime).getTime()) / 36e5;
      if (hoursSinceClosed > 48) throw new Error('Reopen window of 48 hours has passed');

      // Reopen the master ticket
      await client.query(`
        UPDATE tickets
        SET status = 'in_progress', reopened_at = NOW(), reopen_count = reopen_count + 1, closed_by_id = NULL, closed_at = NULL
        WHERE id = $1
      `, [ticketId]);

      // Recursively reopen all child tickets
      await client.query(`
        WITH RECURSIVE child_tickets AS (
          SELECT id FROM tickets WHERE parent_ticket_id = $1
          UNION ALL
          SELECT t.id FROM tickets t
          JOIN child_tickets ct ON t.parent_ticket_id = ct.id
        )
        UPDATE tickets
        SET status = 'in_progress', reopened_at = NOW(), closed_by_id = NULL, closed_at = NULL
        WHERE id IN (SELECT id FROM child_tickets)
      `, [ticketId]);

      await client.query('COMMIT');
      return await this.getTicketDetails(ticketId);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  // ── Get ticket comments ───────────────────────────────────────────────────
  async getComments(ticketId) {
    const result = await pool.query(`
      SELECT tc.*, u.name AS user_name, d.code AS dept_code
      FROM ticket_comments tc
      JOIN users u       ON u.id = tc.user_id
      JOIN departments d ON d.id = u.department_id
      WHERE tc.ticket_id = $1
      ORDER BY tc.created_at ASC
    `, [ticketId]);

    return result.rows;
  }

  // ── Add comment ───────────────────────────────────────────────────────────
  async addComment(ticketId, userId, message) {
    const result = await pool.query(`
      INSERT INTO ticket_comments (ticket_id, user_id, message)
      VALUES ($1, $2, $3) RETURNING *
    `, [ticketId, userId, message]);

    return result.rows[0];
  }

  // ── Log action ───────────────────────────────────────────────────────────
  async logAction(ticketId, userId, action, oldValue, newValue, note) {
    await pool.query(`
      INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, note)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [ticketId, userId, action, oldValue, newValue, note]);
  }

  // ── Get departments list ──────────────────────────────────────────────────
  async getDepartments(companyId) {
    const result = await pool.query(
      `SELECT id, name, code, tier, parent_id FROM departments
       WHERE company_id = $1 OR is_shared = TRUE
       ORDER BY tier, name`,
      [companyId]
    );
    return result.rows;
  }

  // ── Get employees in a department ────────────────────────────────────────
  async getEmployeesByDepartment(departmentId) {
    const result = await pool.query(`
      SELECT
        u.id,
        u.name,
        u.email,
        u.department_id,
        u.company_id,
        u.is_active,
        r.name AS role,
        d.code AS dept_code,
        d.name AS dept_name,
        u.reports_to,
        reporter.name AS reports_to_name
      FROM users u
      JOIN roles r ON r.id = u.role_id
      JOIN departments d ON d.id = u.department_id
      LEFT JOIN users reporter ON reporter.id = u.reports_to
      WHERE u.department_id = $1
        AND u.is_active = TRUE
      ORDER BY u.name ASC
    `, [departmentId]);

    return result.rows;
  }

  // ── Tickets created by this department and transferred out ───────────────
  async getSentTicketsByDepartment(departmentId) {
    const result = await pool.query(`
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.ticket_number,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at,
        t.is_sub_ticket, t.overall_progress,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,
        reporter_assignee.name AS assigned_to_reports_to_name,
        reporter_creator.name AS created_by_reports_to_name,

        tf.code AS transferred_from_code,
        pt.title AS parent_ticket_title,
        pt.ticket_number AS parent_ticket_number,
        t.parent_ticket_id, t.ticket_type,

        -- Fetch department journey
        (
          SELECT json_agg(dept_info) FROM (
            SELECT DISTINCT ON (d.id) 
              d.id as id, d.code, d.name, tl.created_at
            FROM ticket_logs tl
            JOIN departments d ON (
              (tl.action = 'created' AND d.id = t.created_by_dept) OR
              (tl.action = 'transferred' AND d.name = tl.new_value) OR
              (tl.action = 'assigned' AND d.id = t.assigned_dept_id)
            )
            WHERE tl.ticket_id = t.id
            ORDER BY d.id, tl.created_at ASC
          ) dept_info
        ) AS dept_journey,

        ll.action      AS last_action,
        ll.created_at  AS last_updated_at,
        ll.acted_by_name AS last_acted_by_name
      FROM tickets t
      LEFT JOIN users       creator  ON creator.id  = t.created_by_id
      LEFT JOIN departments cd       ON cd.id        = t.created_by_dept
      LEFT JOIN departments ad       ON ad.id        = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id  = t.assigned_to_id
      LEFT JOIN users  reporter_assignee ON reporter_assignee.id = assignee.reports_to
      LEFT JOIN users  reporter_creator ON reporter_creator.id = creator.reports_to
      LEFT JOIN departments tf  ON tf.id        = t.transferred_from
      LEFT JOIN tickets pt     ON pt.id        = t.parent_ticket_id
      LEFT JOIN LATERAL (
        SELECT tl.action, tl.created_at, u.name as acted_by_name
        FROM ticket_logs tl
        JOIN users u ON u.id = tl.acted_by_id
        WHERE tl.ticket_id = t.id
        ORDER BY tl.created_at DESC
        LIMIT 1
      ) ll ON TRUE
      WHERE (t.created_by_dept = $1 OR t.transferred_from = $1)
        AND t.assigned_dept_id <> $1
      ORDER BY t.transferred_at DESC, t.created_at DESC
    `, [departmentId]);

    return result.rows;
  }

  // ── Notification Persistence ─────────────────────────────────────────────
  async createNotification(userId, ticketId, message) {
    const result = await pool.query(`
      INSERT INTO notifications (user_id, ticket_id, message)
      VALUES ($1, $2, $3) RETURNING *
    `, [userId, ticketId, message]);
    return result.rows[0];
  }

  // Batch insert notifications for multiple users
  async createNotifications(userIds, ticketId, message) {
    if (!userIds.length) return [];
    const values = userIds.map((_, i) => `($${i * 3 + 1}, $${i * 3 + 2}, $${i * 3 + 3})`).join(', ');
    const params = userIds.flatMap(id => [id, ticketId, message]);
    const result = await pool.query(`
      INSERT INTO notifications (user_id, ticket_id, message)
      VALUES ${values} RETURNING *
    `, params);
    return result.rows;
  }

  async getUnreadCount(userId) {
    const result = await pool.query(`
      SELECT COUNT(*) AS count FROM notifications
      WHERE user_id = $1 AND is_read = FALSE
    `, [userId]);
    return parseInt(result.rows[0].count, 10);
  }

  // ── Find Users to Notify ─────────────────────────────────────────────────
  async getManagersByDepartment(departmentId) {
    const result = await pool.query(`
      SELECT u.id FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.department_id = $1 AND r.name = 'manager'
    `, [departmentId]);
    return result.rows.map(r => r.id);
  }

  async getTicketParticipants(ticketId) {
    const result = await pool.query(`
      WITH RECURSIVE root_finder AS (
        SELECT id, parent_ticket_id, created_by_id, assigned_to_id, created_by_dept, assigned_dept_id
        FROM tickets WHERE id = $1
        UNION ALL
        SELECT t.id, t.parent_ticket_id, t.created_by_id, t.assigned_to_id, t.created_by_dept, t.assigned_dept_id
        FROM tickets t
        JOIN root_finder rf ON rf.parent_ticket_id = t.id
      ),
      root AS (
        SELECT id FROM root_finder WHERE parent_ticket_id IS NULL LIMIT 1
      ),
      all_tree_tickets AS (
        SELECT id, parent_ticket_id, created_by_id, assigned_to_id, created_by_dept, assigned_dept_id
        FROM tickets WHERE id = (SELECT id FROM root)
        UNION ALL
        SELECT t.id, t.parent_ticket_id, t.created_by_id, t.assigned_to_id, t.created_by_dept, t.assigned_dept_id
        FROM tickets t
        JOIN all_tree_tickets att ON att.id = t.parent_ticket_id
      )
      SELECT DISTINCT user_id FROM (
        -- All creators across the entire tree
        SELECT created_by_id AS user_id FROM all_tree_tickets
        UNION
        -- All direct assignees across the entire tree
        SELECT assigned_to_id FROM all_tree_tickets WHERE assigned_to_id IS NOT NULL
        UNION
        -- All sub-department assignees across the entire tree
        SELECT std.assigned_to_id FROM all_tree_tickets att
        JOIN sub_ticket_departments std ON std.ticket_id = att.id
        WHERE std.assigned_to_id IS NOT NULL
        UNION
        -- All users in departments involved anywhere in the tree
        SELECT u.id FROM users u
        WHERE u.department_id IN (
            SELECT created_by_dept FROM all_tree_tickets WHERE created_by_dept IS NOT NULL
            UNION
            SELECT assigned_dept_id FROM all_tree_tickets WHERE assigned_dept_id IS NOT NULL
            UNION
            SELECT department_id FROM sub_ticket_departments WHERE ticket_id IN (SELECT id FROM all_tree_tickets)
          )
        UNION
        -- Always include CEO
        SELECT u.id FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE r.name = 'ceo'
      ) sub
    `, [ticketId]);
    return result.rows.map(r => r.user_id);
  }

  // ── Get user by ID ───────────────────────────────────────────────────────
  async getUserById(userId) {
    const result = await pool.query(`
      SELECT u.id, u.name, u.email, u.department_id, u.company_id, u.is_active, r.name AS role
      FROM users u
      JOIN roles r ON r.id = u.role_id
      WHERE u.id = $1
    `, [userId]);
    return result.rows[0] || null;
  }

  // ── Get ticket logs/history ─────────────────────────────────────────────
  async getTicketLogs(ticketId) {
    const result = await pool.query(`
      SELECT 
        tl.id, tl.ticket_id, tl.action, tl.old_value, tl.new_value, tl.note, tl.created_at,
        u.id AS acted_by_id,
        u.name AS acted_by_name,
        d.code AS dept_code,
        d.name AS dept_name
      FROM ticket_logs tl
      LEFT JOIN users u ON u.id = tl.acted_by_id
      LEFT JOIN departments d ON d.id = u.department_id
      WHERE tl.ticket_id = $1
      ORDER BY tl.created_at ASC
    `, [ticketId]);

    return result.rows;
  }

  // ── Sub-Ticket: get department assignments ────────────────────────────────
  async getSubTicketDepartments(ticketId) {
    const result = await pool.query(`
      SELECT
        std.id, std.ticket_id, std.department_id, std.task_description,
        std.status, std.progress_percent, std.assigned_to_id, std.completed_at,
        std.created_at, std.updated_at,
        d.name AS department_name, d.code AS department_code,
        u.name AS assigned_to_name
      FROM sub_ticket_departments std
      JOIN departments d ON d.id = std.department_id
      LEFT JOIN users u ON u.id = std.assigned_to_id
      WHERE std.ticket_id = $1
      ORDER BY d.name ASC
    `, [ticketId]);
    return result.rows;
  }

  async enrichTicketWithSubData(ticket) {
    if (!ticket || !ticket.is_sub_ticket) return ticket;
    const departments = await this.getSubTicketDepartments(ticket.id);
    ticket.sub_departments = departments;
    ticket.department_count = departments.length;
    ticket.completed_department_count = departments.filter(d => d.status === 'completed' || d.status === 'approved').length;
    return ticket;
  }

  async enrichTicketsWithSubData(tickets) {
    const subTickets = tickets.filter(t => t.is_sub_ticket);
    if (subTickets.length === 0) return tickets;

    const ids = subTickets.map(t => t.id);
    const result = await pool.query(`
      SELECT
        std.id, std.ticket_id, std.department_id, std.task_description,
        std.status, std.progress_percent, std.assigned_to_id, std.completed_at,
        d.name AS department_name, d.code AS department_code,
        u.name AS assigned_to_name
      FROM sub_ticket_departments std
      JOIN departments d ON d.id = std.department_id
      LEFT JOIN users u ON u.id = std.assigned_to_id
      WHERE std.ticket_id = ANY($1::int[])
      ORDER BY std.ticket_id, d.name ASC
    `, [ids]);

    const byTicket = {};
    for (const row of result.rows) {
      if (!byTicket[row.ticket_id]) byTicket[row.ticket_id] = [];
      byTicket[row.ticket_id].push(row);
    }

    return tickets.map(t => {
      if (!t.is_sub_ticket) return t;
      const depts = byTicket[t.id] || [];
      return {
        ...t,
        sub_departments: depts,
        department_count: depts.length,
        completed_department_count: depts.filter(d => d.status === 'completed' || d.status === 'approved').length,
      };
    });
  }

  async _recalculateSubTicketProgress(ticketId, client = pool) {
    const agg = await client.query(`
      SELECT
        COALESCE(ROUND(AVG(progress_percent)), 0)::int AS avg_progress,
        COUNT(*) FILTER (WHERE status IN ('completed')) AS completed_count,
        COUNT(*) FILTER (WHERE status IN ('approved')) AS approved_count,
        COUNT(*) AS total_count,
        COUNT(*) FILTER (WHERE status IN ('in_progress', 'pending_approval')) AS in_progress_count
      FROM sub_ticket_departments
      WHERE ticket_id = $1
    `, [ticketId]);

    const { avg_progress, completed_count, approved_count, total_count, in_progress_count } = agg.rows[0];
    let newStatus = 'open';
    if (Number(completed_count) === Number(total_count) && total_count > 0) {
      newStatus = 'completed';
    } else if (Number(in_progress_count) > 0 || Number(avg_progress) > 0) {
      newStatus = 'in_progress';
    }

    await client.query(`
      UPDATE tickets
      SET overall_progress = $1, status = $2
      WHERE id = $3 AND is_sub_ticket = TRUE
    `, [avg_progress, newStatus, ticketId]);

    return { avg_progress, newStatus, approved_count };
  }

  async createSubTicket({ title, description, priority, dueDate, createdBy, departments, parentTicketId = null }) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const ticketResult = await client.query(`
        INSERT INTO tickets
          (title, description, priority, assigned_dept_id, due_date,
           created_by_id, created_by_dept, assigned_to_id, status, is_sub_ticket, overall_progress, parent_ticket_id, ticket_type)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'in_progress', TRUE, 0, $9, 'multi_task')
        RETURNING id
      `, [
        title, description, priority,
        createdBy.department_id,
        dueDate || null,
        createdBy.id,
        createdBy.department_id,
        createdBy.id,
        parentTicketId
      ]);

      const ticketId = ticketResult.rows[0].id;

      for (const dept of departments) {
        await client.query(`
          INSERT INTO sub_ticket_departments
            (ticket_id, department_id, task_description, status, progress_percent)
          VALUES ($1, $2, $3, 'open', 0)
        `, [ticketId, dept.departmentId, dept.taskDescription]);
      }

      await client.query('COMMIT');
      const ticket = await this.getTicketDetails(ticketId);
      return await this.enrichTicketWithSubData(ticket);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async updateSubDeptProgress(ticketId, departmentId, { status }) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const updates = [];
      const params = [ticketId, departmentId];
      let paramIdx = 3;
      const now = new Date();

      if (status != null) {
        updates.push(`status = $${paramIdx}`);
        params.push(status);
        paramIdx++;
        if (status === 'completed') {
          updates.push(`completed_at = NOW()`);
          updates.push(`progress_percent = 100`);
          updates.push(`updated_at = NOW()`);
        } else if (status === 'approved') {
          updates.push(`progress_percent = 100`);
          updates.push(`updated_at = NOW()`);
        } else if (status === 'pending_approval') {
          updates.push(`progress_percent = 100`);
          updates.push(`updated_at = NOW()`);
        } else if (status === 'in_progress') {
          updates.push(`progress_percent = GREATEST(progress_percent, 1)`);
        } else if (status === 'open') {
          updates.push(`completed_at = NULL`);
        }
      }

      if (updates.length === 0) {
        throw new Error('No updates provided');
      }

      const result = await client.query(`
        UPDATE sub_ticket_departments
        SET ${updates.join(', ')}
        WHERE ticket_id = $1 AND department_id = $2
        RETURNING *
      `, params);

      if (result.rows.length === 0) {
        throw new Error('Department assignment not found');
      }

      await this._recalculateSubTicketProgress(ticketId, client);

      await client.query('COMMIT');

      const ticket = await this.getTicketDetails(ticketId);
      return await this.enrichTicketWithSubData(ticket);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async assignSubDeptToEmployee(ticketId, departmentId, employeeId, managerId) {
    const empCheck = await pool.query(
      `SELECT u.id FROM users u WHERE u.id = $1 AND u.department_id = (
         SELECT u2.department_id FROM users u2 WHERE u2.id = $2
       )`,
      [employeeId, managerId]
    );

    if (empCheck.rows.length === 0) {
      throw new Error('Employee not in same department');
    }

    const result = await pool.query(`
      UPDATE sub_ticket_departments
      SET assigned_to_id = $1,
          status = 'in_progress',
          progress_percent = GREATEST(progress_percent, 1),
          updated_at = NOW()
      WHERE ticket_id = $2 AND department_id = $3
      RETURNING *
    `, [employeeId, ticketId, departmentId]);

    if (result.rows.length === 0) {
      throw new Error('Department assignment not found');
    }

    await this._recalculateSubTicketProgress(ticketId);
    const ticket = await this.getTicketDetails(ticketId);
    return await this.enrichTicketWithSubData(ticket);
  }

  async completeSubTicket(ticketId, userId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      await client.query(`
        UPDATE sub_ticket_departments
        SET status = 'completed', completed_at = NOW(), updated_at = NOW()
        WHERE ticket_id = $1 AND status = 'approved'
      `, [ticketId]);

      await client.query(`
        UPDATE tickets
        SET status = 'completed', overall_progress = 100, closed_at = NOW()
        WHERE id = $1 AND is_sub_ticket = TRUE
      `, [ticketId]);

      await client.query('COMMIT');

      const ticket = await this.getTicketDetails(ticketId);
      return await this.enrichTicketWithSubData(ticket);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async reopenSubDept(ticketId, departmentId, nextDeptId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      await client.query(`
        UPDATE sub_ticket_departments
        SET status = 'in_progress', progress_percent = 1,
            completed_at = NULL, updated_at = NOW()
        WHERE ticket_id = $1 AND department_id = $2
      `, [ticketId, departmentId]);

      // Cascade unlock: clear completed_at on the next department so its
      // 48-hour window is reset when the user chooses to reopen it.
      if (nextDeptId) {
        await client.query(`
          UPDATE sub_ticket_departments
          SET completed_at = NULL, updated_at = NOW()
          WHERE ticket_id = $1 AND department_id = $2
        `, [ticketId, nextDeptId]);
      }

      await client.query('COMMIT');

      const ticket = await this.getTicketDetails(ticketId);
      return await this.enrichTicketWithSubData(ticket);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  // ── Get analytics grouped by department ──────────────────────────────────
  async getAnalyticsByDepartment() {
    const result = await pool.query(`
      SELECT
        d.id AS dept_id,
        d.code AS dept_code,
        d.name AS dept_name,
        COUNT(t.id)                                          AS total,
        COUNT(t.id) FILTER (WHERE t.status = 'open')        AS open,
        COUNT(t.id) FILTER (WHERE t.status = 'in_progress') AS in_progress,
        COUNT(t.id) FILTER (WHERE t.status = 'completed')   AS completed,
        COUNT(t.id) FILTER (WHERE t.status = 'closed')      AS closed,
        COUNT(t.id) FILTER (WHERE t.priority = 'urgent')    AS urgent,
        COUNT(t.id) FILTER (WHERE t.priority = 'high')      AS high_priority,
        COUNT(t.id) FILTER (WHERE t.due_date < NOW() AND t.status NOT IN ('completed','closed')) AS overdue,
        ROUND(AVG(EXTRACT(EPOCH FROM (COALESCE(t.closed_at, t.updated_at) - t.created_at)) / 3600)::numeric, 2) AS avg_resolution_hours
      FROM departments d
      LEFT JOIN tickets t ON t.assigned_dept_id = d.id
      GROUP BY d.id, d.code, d.name
      ORDER BY d.name ASC
    `);

    return result.rows;
  }

  // ── Check if department already exists in project tree ──────────────────────
  async isDepartmentUsedInTree(ticketId, deptId) {
    const result = await pool.query(`
      WITH RECURSIVE subtree AS (
        SELECT id, parent_ticket_id, assigned_dept_id FROM tickets WHERE id = $1
        UNION ALL
        SELECT t.id, t.parent_ticket_id, t.assigned_dept_id
        FROM tickets t JOIN subtree s ON t.parent_ticket_id = s.id
      )
      SELECT EXISTS (SELECT 1 FROM subtree WHERE assigned_dept_id = $2) AS used
    `, [ticketId, deptId]);
    return result.rows[0].used;
  }

  // ── Check if ticket has any active (not completed/closed) descendants ──────
  async hasActiveChildren(ticketId) {
    const result = await pool.query(`
      WITH RECURSIVE descendants AS (
        SELECT id, status FROM tickets WHERE parent_ticket_id = $1
        UNION ALL
        SELECT t.id, t.status FROM tickets t
        JOIN descendants d ON t.parent_ticket_id = d.id
      )
      SELECT EXISTS (SELECT 1 FROM descendants WHERE status NOT IN ('completed', 'closed')) AS active
    `, [ticketId]);
    return result.rows[0].active;
  }

  // ── Check if all direct children are completed/closed ──────────────────────
  async allChildrenCompleted(ticketId) {
    const result = await pool.query(`
      SELECT COUNT(*)::int AS total,
             COUNT(*) FILTER (WHERE status IN ('completed', 'closed'))::int AS done
      FROM tickets WHERE parent_ticket_id = $1
    `, [ticketId]);
    const row = result.rows[0];
    return row.total > 0 && row.total === row.done;
  }

  // ── Get parent chain from immediate parent up to root ──────────────────────
  async getParentChain(ticketId) {
    const result = await pool.query(`
      WITH RECURSIVE ancestors AS (
        SELECT id, parent_ticket_id FROM tickets WHERE id = $1
        UNION ALL
        SELECT t.id, t.parent_ticket_id
        FROM tickets t JOIN ancestors a ON t.id = a.parent_ticket_id
      )
      SELECT id FROM ancestors WHERE id != $1 AND parent_ticket_id IS NOT NULL
      UNION ALL
      SELECT id FROM ancestors WHERE id != $1 AND parent_ticket_id IS NULL
    `, [ticketId]);
    return result.rows.map(r => r.id);
  }
}

module.exports = new TicketRepository();
