class ConstStrings {
  ConstStrings._();

  // ──────────────────────────────────────────────
  // App
  // ──────────────────────────────────────────────
  static const String appName = 'TaskNest';
  static const String appShortName = 'TN';
  static const String appDescription = 'Task Management System';
  static const String copyright = '\u00a9 2025';
  static const String allRightsReserved = '. All rights reserved.';
  static const String printedFrom = 'Printed from TaskNest';

  // ──────────────────────────────────────────────
  // Auth — Login
  // ──────────────────────────────────────────────
  static const String loginWelcomeBack = 'Welcome back';
  static const String signInTo = 'Sign in to ';
  static const String employeeCode = 'Employee Code';
  static const String employeeCodeRequired = 'Employee code is required';
  static const String password = 'Password';
  static const String passwordRequired = 'Password is required';
  static const String logIn = 'Log In';
  static const String loginSuccess = 'Login Success';

  // ──────────────────────────────────────────────
  // Auth — Signup
  // ──────────────────────────────────────────────
  static const String createAccount = 'Create Account';
  static const String createAnAccount = 'Create an account';
  static const String fillDetailsToGetStarted =
      'Fill in the details to get started';
  static const String join = 'Join ';
  static const String fullName = 'Full Name';

  static const String nameRequired = 'Name is required';
  static const String emailAddress = 'Email address';
  static const String emailRequired = 'Required';
  static const String min6Chars = 'Min 7 characters';
  static const String selectRole = 'Select Role';
  static const String selectCompany = 'Select Company';
  static const String selectDepartment = 'Select Department';
  static const String signUp = 'Sign Up';
  static const String alreadyHaveAccountLogin =
      'Already have an account? Log in';
  static const String alreadyHaveAccountLoginAlt =
      'Already have an account? Login';
  static const String accountCreatedSuccessfully =
      'Account created successfully!';
  static const String processingSignup = 'Processing Signup...';

  // ──────────────────────────────────────────────
  // Auth — Forgot Password
  // ──────────────────────────────────────────────
  static const String resetPassword = 'Reset password';
  static const String enterEmailToReset =
      'Enter your email address to receive a secure password reset link.';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogIn = 'Back to Log In';
  static const String enterResetCode = 'Enter reset code';
  static const String codeSentTo = 'A 6-digit code was sent to ';
  static const String codeExpiresIn = '. It expires in ';
  static const String minutes = ' minutes.';
  static const String devCode = 'Dev code: ';
  static const String resetCode = 'Reset code';
  static const String resetCodeRequired = 'Reset code is required';
  static const String codeMustBe6Digits = 'Code must be 6 digits';
  static const String newPassword = 'New password';
  static const String passwordRequiredMin = 'Password is required';
  static const String passwordMin6Chars =
      'Password must be at least 6 characters';
  static const String confirmNewPassword = 'Confirm new password';
  static const String pleaseConfirmPassword = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String resetPasswordBtn = 'Reset Password';
  static const String passwordResetSuccess =
      'Password reset successful! You can now log in with your new password.';
  static const String passwordResetFailed = 'Password Reset Failed';

  // ──────────────────────────────────────────────
  // Auth — First Login Reset
  // ──────────────────────────────────────────────
  static const String setYourPassword = 'Set your password';
  static const String welcomeSetNewPassword =
      'Welcome! Please set a new password for ';
  static const String setPasswordAndLogin = 'Set Password & Login';

  // ──────────────────────────────────────────────
  // Auth — Registration Pending
  // ──────────────────────────────────────────────
  static const String registrationPending = 'Registration Pending';
  static const String registrationPendingMessage =
      'Your registration is pending approval. Please wait for confirmation';
  static const String accountPendingApproval = 'Account Pending Approval';

  // ──────────────────────────────────────────────
  // Auth — Errors
  // ──────────────────────────────────────────────
  static const String authenticationFailed = 'Authentication Failed';
  static const String invalidCredentials =
      'Invalid credentials. Please try again.';
  static const String signupFailed = 'Signup Failed';

  // ──────────────────────────────────────────────
  // Common
  // ──────────────────────────────────────────────
  static const String success = 'Success';
  static const String error = 'Error';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String submit = 'Submit';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String create = 'Create';
  static const String assign = 'Assign';
  static const String required_ = 'Required';
  static const String loading = 'Loading...';
  static const String none = 'None';
  static const String unassigned = 'Unassigned';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String confirm = 'Confirm';
  static const String print = 'Print';
  static const String printPreview = 'Print Preview';
  static const String previous = 'Previous';
  static const String next = 'Next';

  // ──────────────────────────────────────────────
  // Navigation
  // ──────────────────────────────────────────────
  static const String navDashboard = 'Dashboard';
  static const String navAllDeptTickets = 'All Department Tickets';
  static const String navDeptTickets = "Department's Tickets";
  static const String navMyTickets = 'My Tickets';
  static const String navNewTicket = 'New Ticket';
  static const String navSentSubTickets = 'Sent Sub-Tickets';
  static const String navRecentActivities = 'Recent Activities';
  static const String navTicketTypes = 'Ticket Types';
  static const String navAdminPanel = 'Admin Panel';
  static const String navNotifications = 'Notifications';
  static const String taskify = 'Taskify';

  // ──────────────────────────────────────────────
  // Dashboard
  // ──────────────────────────────────────────────
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String dashboardSubtitle =
      "Here's what's happening with your tickets today";
  static const String refresh = 'Refresh';
  static const String logout = 'Logout';
  static const String overview = 'Overview';
  static const String resolutionMetrics = 'Resolution Metrics';
  static const String priorityBreakdown = 'Priority Breakdown';
  static const String statTotal = 'Total';
  static const String statOpen = 'Open';
  static const String statInProgress = 'In Progress';
  static const String statCompleted = 'Completed';
  static const String statClosed = 'Closed';
  static const String statUrgent = 'Urgent';
  static const String statHighPri = 'High Pri.';
  static const String statOverdue = 'Overdue';
  static const String avgResolutionTime = 'Avg. Resolution Time';
  static const String perTicketClosed = 'per ticket closed';
  static const String completionRate = 'Completion Rate';
  static const String overdueRate = 'Overdue Rate';
  static const String overdueTickets = 'overdue tickets';
  static const String criticalLoad = 'Critical Load';
  static const String urgentTicketsOpen = 'urgent tickets open';
  static const String priorityMediumLow = 'Medium & Low';
  static const String priorityDistribution = 'Priority Distribution';
  static const String statusSummary = 'Status Summary';
  static const String highPriority = 'High';
  static const String ticketsOfTotal = 'tickets';
  static const String by = 'By';
  static const String status = 'Status';
  static const String system = 'System';
  static const String returnedTo = 'Returned to';
  static const String stateForFurtherWork = 'state for further work.';

  // ──────────────────────────────────────────────
  // Tickets — Status & Priority
  // ──────────────────────────────────────────────
  static const String statusAll = 'All';
  static const String statusOpen = 'Open';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusClosed = 'Closed';
  static const String statusDone = 'DONE';
  static const String statusOk = 'OK';
  static const String statusReview = 'REVIEW';
  static const String statusActive = 'ACTIVE';
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
  static const String priorityUrgent = 'Urgent';
  static const String priorityAll = 'All';

  // ──────────────────────────────────────────────
  // Tickets — List & Filters
  // ──────────────────────────────────────────────
  static const String tickets = 'Tickets';
  static const String listView = 'List';
  static const String boardView = 'Board';
  static const String clearFilters = 'Clear Filters';
  static const String searchHint = 'Search tickets by #, name, dept, date...';
  static const String myTeam = 'MY TEAM';
  static const String ticketsFromYourTeam = 'tickets from your team';
  static const String noTickets = 'No tickets';
  static const String noTicketsYet = 'No tickets yet';
  static const String noMatchingTickets = 'No matching tickets';
  static const String ticketsWillAppear =
      'Tickets assigned to your department will appear here';
  static const String tryAdjustingFilters =
      'Try adjusting or clearing your filters';
  static const String assignedTickets = ' assigned tickets';
  static const String sortedByNewest = ' \u00b7 sorted by newest first';
  static const String totalSent = 'Total Sent';
  static const String active = 'Active';
  static const String ticketsForwarded =
      ' tickets forwarded to other departments';
  static const String pageOf = 'Page ';
  static const String of_ = ' of ';

  // ──────────────────────────────────────────────
  // Tickets — Detail
  // ──────────────────────────────────────────────
  static const String multiTask = 'MULTI TASK';
  static const String subTicket = 'SUB TICKET';
  static const String multiTaskLabel = 'Multi Task';
  static const String subTicketLabel = 'Sub Ticket';
  static const String standardLabel = 'Standard';
  static const String overdue = 'OVERDUE';
  static const String departmentBreakdown = 'Department Breakdown';
  static const String description = 'Description';
  static const String actions = 'Actions';
  static const String progress = 'Progress';
  static const String overallProgress = 'Overall Progress';
  static const String ticketDetails = 'Ticket Details';
  static const String createdBy = 'Created By';
  static const String createdDept = 'Created Dept';
  static const String assignedDept = 'Assigned Dept';
  static const String assignedTo = 'Assigned To';
  static const String created = 'Created';
  static const String dueDate = 'Due Date';
  static const String closedAt = 'Closed At';
  static const String reopenCount = 'Reopen Count';
  static const String transferredFrom = 'Transferred From';
  static const String lastAction = 'Last Action';
  static const String lastActedBy = 'Last Acted By';
  static const String lastActionAt = 'Last Action At';
  static const String hasSubTasks = 'HAS SUB-TASKS';
  static const String subTickets = 'Sub Tickets';
  static const String childOf = 'Child of ';
  static const String now = 'NOW';

  // ──────────────────────────────────────────────
  // Tickets — Actions
  // ──────────────────────────────────────────────
  static const String selfAssign = 'Self Assign';
  static const String assignToEmployee = 'Assign to Employee';
  static const String markDone = 'Mark Done';
  static const String finalizeAndClose = 'Finalize & Close';
  static const String createSubTicket = 'Create Sub Ticket';
  static const String reopen = 'Reopen';
  static const String noEmployeesInDept =
      'No employees found in your department';
  static const String assignTicket = 'Assign Ticket';
  static const String employee = 'Employee';
  static const String addRemarkBefore = 'Add remark before ';
  static const String workSummaryHint = 'Write work summary / closing remark';
  static const String noDeptsForSubTicket =
      'No departments available for sub-ticket';
  static const String title = 'Title';
  static const String enterSubTicketTitle = 'Enter sub-ticket title';
  static const String titleRequired = 'Title is required';
  static const String descriptionLabel = 'Description';
  static const String enterTaskDescription = 'Enter task description';
  static const String descriptionRequired = 'Description is required';
  static const String targetDepartment = 'Target Department';
  static const String completeTicket = 'Complete Ticket';
  static const String selfAssignToTask = 'Self-Assign to this Task';
  static const String completionRemarkHint =
      'Last comment before marking as done (required)';
  static const String completionRemarkRequired =
      'A completion remark is required';
  static const String markAsDone = 'Mark as Done';
  static const String approveCompletion = 'Approve Completion';
  static const String workSubmittedWaitingApproval =
      'Work submitted. Waiting for manager approval.';
  static const String managerApprovedWaitingFinalize =
      'Manager approved. Waiting for creator to finalize.';
  static const String managerApprovedYouCanComplete =
      'Manager approved. You can complete the ticket or reopen this department.';
  static const String reopenThisDept = 'Reopen this Department';
  static const String assignedToLabel = 'Assigned to: ';

  // ──────────────────────────────────────────────
  // Tickets — Comments
  // ──────────────────────────────────────────────
  static String commentsCount(int count) => 'Comments ($count)';
  static const String writeCommentHint = 'Write a comment or update...';
  static const String commentsClosed = 'Comments are closed';
  static const String post = 'Post';
  static const String commentsClosedForTicket =
      'Comments are closed for this ticket.';
  static const String noCommentsYet = 'No comments yet.';

  // ──────────────────────────────────────────────
  // Tickets — Progress Timeline
  // ──────────────────────────────────────────────
  static const String stepTicketCreated = 'Ticket Created';
  static const String stepTicketCreatedDesc = 'Request logged in the system.';
  static const String stepInProgress = 'In Progress';
  static const String stepInProgressDesc = 'A resolver is working on this.';
  static const String stepCompleted = 'Completed';
  static const String stepCompletedDesc = 'Task finished, awaiting closure.';
  static const String stepClosed = 'Closed';
  static const String stepClosedDesc = 'Resolved and archived.';

  // ──────────────────────────────────────────────
  // Tickets — History Timeline
  // ──────────────────────────────────────────────
  static const String history = 'History';
  static const String noHistoryRecords =
      'No history records found for this ticket.';
  static const String historyInitiated = 'TICKET INITIATED';
  static const String historyAssigned = 'PERSONNEL ASSIGNMENT';
  static const String historyTransferred = 'DEPARTMENTAL TRANSFER';
  static const String historySubTicket = 'SUB-TICKET GENERATED';
  static const String historyUpdated = 'WORKFLOW UPDATE';
  static const String historyComment = 'NEW COMMENT';
  static const String historyReopened = 'TICKET REOPENED';
  static const String historyOrigin = 'Origin';
  static const String historyTransferredTo = 'Transferred to';
  static const String historyTarget = 'Target';
  static const String historyUnassigned = 'Unassigned';
  static const String historyAssignedTo = 'Assigned to';
  static const String historyPersonnel = 'Personnel';
  static const String historyPrev = 'Prev:';
  static const String historyBornIn = 'Ticket born in';
  static const String historyDepartment = 'Department';
  static const String historyReturned =
      'Returned to ... state for further work.';
  static const String printedBy = 'Printed by';

  // ──────────────────────────────────────────────
  // Tickets — Lifecycle Path
  // ──────────────────────────────────────────────
  static const String lifecyclePath = 'LIFECYCLE PATH';
  static const String origin = 'ORIGIN';
  static const String current = 'CURRENT';
  static const String transfer = 'TRANSFER';
  static const String link = 'LINK';

  // ──────────────────────────────────────────────
  // Tickets — Type Section
  // ──────────────────────────────────────────────
  static const String standardTickets = 'Standard Tickets';
  static const String singleDeptTickets = 'Single-department tickets';
  static const String subTicketsTitle = 'Sub-Tickets';
  static const String childSubTickets = 'Child sub-tickets';
  static const String multiTaskTickets = 'Multi Task Tickets';
  static const String multiDeptTasks = 'Multi-department tasks';
  static const String ticketTypes = 'Ticket Types';
  static const String total = ' total';
  static const String ticketsLabel = 'tickets';

  // ──────────────────────────────────────────────
  // Tickets — Create
  // ──────────────────────────────────────────────
  static const String creatingSubTicketFor = 'Creating sub-ticket for #';
  static const String createMultiTicket = 'Create Multi Ticket';
  static const String createStandardTicket = 'Create Standard Ticket';
  static const String fillDetailsAndAssign =
      'Fill in the details and assign to a department.';
  static const String departmentTickets = 'Department Tickets';
  static const String titleFor = 'Title for ';
  static const String titleIsRequiredFor = 'Title is required for ';
  static const String describeTaskFor = 'Describe task for ';
  static const String descriptionIsRequiredFor = 'Description is required for ';
  static const String submitting = 'Submitting...';
  static const String submitTicket = 'Submit Ticket';
  static const String selectAtLeast2Depts =
      'Select at least 2 departments for a multi-task ticket';
  static const String addTaskDescriptionFor = 'Add a task description for ';
  static const String createMultiTaskTicket = 'Create Multi Task Ticket';
  static const String multiDeptCollabTicket =
      'Multi-department collaborative ticket (Manager only)';
  static const String overallDescription = 'Overall Description';
  static const String describeOverallObjective =
      'Describe the overall objective across departments...';
  static const String descriptionIsRequired = 'Description is required';
  static const String selectDepartments = 'Select Departments';
  static const String pick2OrMoreDepts =
      'Pick 2 or more departments. A task box appears for each.';
  static const String departmentTasks = 'Department Tasks';
  static const String creating = 'Creating...';
  static const String createSubTicketBtn = 'Create Sub-Ticket';
  static const String taskInstructionsFor = 'Task instructions for ';
  static const String taskDescriptionRequired = 'Task description required';
  static const String pickDueDateOptional = 'Pick a due date (optional)';

  // ──────────────────────────────────────────────
  // Tickets — Empty States
  // ──────────────────────────────────────────────
  static const String noTicketsAssigned = 'No tickets assigned to you';
  static const String newTicketsWillAppear =
      'New tickets will appear here when assigned';
  static const String noRecentActivity = 'No recent activity';
  static const String ticketActivityWillAppear =
      'Ticket activity will appear here as updates come in';
  static const String noSubTicketsSent = 'No sub-tickets sent yet';
  static const String subTicketsWillAppear =
      'Sub-tickets created for other departments will appear here';
  static const String invalidSection = 'Invalid Section';

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────
  static const String justNow = 'just now';
  static const String markAllRead = 'Mark all read';
  static const String noNotifications = 'No notifications yet';

  // ──────────────────────────────────────────────
  // Print / HTML
  // ──────────────────────────────────────────────
  static const String htmlStatus = 'Status';
  static const String htmlPriority = 'Priority';
  static const String htmlDepartment = 'Department';
  static const String htmlCreatedBy = 'Created By';
  static const String htmlAssignedTo = 'Assigned To';
  static const String htmlCreatedDate = 'Created Date';
  static const String htmlDescription = 'DESCRIPTION';
  static const String printTicket = 'Print ticket';

  // ──────────────────────────────────────────────
  // Admin — Common
  // ──────────────────────────────────────────────
  static const String addUser = 'Add User';
  static const String addDepartment = 'Add Department';
  static const String searchByNameOrCode = 'Search by name or code...';
  static const String searchByNameEmailCodeDept =
      'Search by name, code, email, department...';
  static const String searchByNameOrEmail = 'Search by name or email...';
  static const String searchTickets = 'Search tickets...';
  static const String allStatus = 'All Status';
  static const String deleteDepartment = 'Delete Department?';
  static const String deleteCannotUndone = '? This cannot be undone.';
  static const String nameLabel = 'Name';
  static const String codeLabel = 'Code';
  static const String companyLabel = 'Company';
  static const String umEnterprises = 'UM Enterprises';
  static const String matrixPharma = 'Matrix Pharma';
  static const String tierLabel = 'Tier';
  static const String upper = 'Upper';
  static const String lower = 'Lower';
  static const String parentDepartment = 'Parent Department';
  static const String noneTopLevel = 'None (top-level)';
  static const String sharedDepartment = 'Shared Department';
  static const String visibleAcrossCompanies = 'Visible across all companies';
  static const String deleteTicket = 'Delete Ticket?';

  // ──────────────────────────────────────────────
  // Admin — Users
  // ──────────────────────────────────────────────
  static const String emailLabel = 'Email';
  static const String editTooltip = 'Edit';
  static const String approve = 'Approve';
  static const String approveUser = 'Approve User?';
  static const String approveUserContent =
      '? They will be able to log in immediately.';
  static const String deactivateActivate = 'Deactivate';
  static const String resetPasswordTitle = 'Reset Password?';
  static const String resetPasswordContent =
      ' to UM@2024? They will be forced to change it on next login.';
  static const String reset = 'Reset';
  static const String employeeCodeLabel = 'Employee Code';
  static const String designationLabel = 'Designation';
  static const String newPasswordLabel =
      'New Password (leave blank to keep current)';
  static const String roleLabel = 'Role';
  static const String roleDeveloper = 'Developer';
  static const String roleCeo = 'CEO';
  static const String roleManager = 'Manager';
  static const String roleEmployee = 'Employee';
  static const String departmentIdLabel = 'Department ID';
  static const String selectReportsTo = 'Select Reports To';
  static const String reportsToLabel = 'Reports To';

  // ──────────────────────────────────────────────
  // Admin — Success Messages
  // ──────────────────────────────────────────────
  static const String userCreatedSuccess = 'User created successfully';
  static const String userUpdatedSuccess = 'User updated successfully';
  static const String userDeactivatedSuccess = 'User deactivated successfully';
  static const String userApprovedSuccess = 'User approved successfully';
  static const String deptCreatedSuccess = 'Department created successfully';
  static const String deptUpdatedSuccess = 'Department updated successfully';
  static const String deptDeletedSuccess = 'Department deleted successfully';
  static const String ticketDeletedSuccess = 'Ticket deleted successfully';

  // ──────────────────────────────────────────────
  // Auth — Password Reset Errors (kept unique only)
  // ──────────────────────────────────────────────
  static const String passwordResetErrorTitle = 'Password Reset Error';
  static const String passwordResetErrorMsg =
      'An error occurred while resetting your password. Please try again later.';
  static const String passwordResetEmailSentTitle = 'Password Reset Email Sent';
  static const String passwordResetEmailSentMsg =
      'A password reset email has been sent to your email address. Please check your inbox.';
  static const String passwordResetEmailErrorTitle =
      'Password Reset Email Error';
  static const String passwordResetEmailErrorMsg =
      'An error occurred while sending the password reset email. Please try again later.';
  static const String passwordResetEmailNotFoundTitle =
      'Password Reset Email Not Found';
  static const String passwordResetEmailNotFoundMsg =
      'The email address you entered is not registered. Please check and try again.';
  static const String passwordResetEmailInvalidTitle =
      'Password Reset Email Invalid';
  static const String passwordResetEmailInvalidMsg =
      'The email address you entered is invalid. Please check and try again.';
  static const String passwordResetEmailExpiredTitle =
      'Password Reset Email Expired';
  static const String passwordResetEmailExpiredMsg =
      'The password reset email you entered has expired. Please request a new one.';
  static const String passwordResetEmailAlreadyUsedTitle =
      'Password Reset Email Already Used';
  static const String passwordResetEmailAlreadyUsedMsg =
      'The password reset email you entered has already been used. Please request a new one.';
  static const String passwordResetEmailNotSentTitle =
      'Password Reset Email Not Sent';
  static const String passwordResetEmailNotSentMsg =
      'The password reset email could not be sent. Please try again later.';
  static const String passwordResetEmailNotDeliveredTitle =
      'Password Reset Email Not Delivered';
  static const String passwordResetEmailNotDeliveredMsg =
      'The password reset email could not be delivered. Please check your email address and try again.';
  static const String passwordResetEmailNotOpenedTitle =
      'Password Reset Email Not Opened';
  static const String passwordResetEmailNotOpenedMsg =
      'The password reset email has not been opened. Please check your inbox and try again.';
  static const String passwordResetEmailNotClickedTitle =
      'Password Reset Email Not Clicked';
  static const String passwordResetEmailNotClickedMsg =
      'The password reset email has not been clicked. Please check your inbox and try again.';
  static const String passwordResetEmailNotConfirmedTitle =
      'Password Reset Email Not Confirmed';
  static const String passwordResetEmailNotConfirmedMsg =
      'The password reset email has not been confirmed. Please check your inbox and try again.';
  static const String passwordResetEmailNotVerifiedTitle =
      'Password Reset Email Not Verified';
  static const String passwordResetEmailNotVerifiedMsg =
      'The password reset email has not been verified. Please check your inbox and try again.';
  static const String passwordResetEmailNotAuthenticatedTitle =
      'Password Reset Email Not Authenticated';
  static const String passwordResetEmailNotAuthenticatedMsg =
      'The password reset email has not been authenticated. Please check your inbox and try again.';
  static const String passwordResetEmailNotAuthorizedTitle =
      'Password Reset Email Not Authorized';
  static const String passwordResetEmailNotAuthorizedMsg =
      'The password reset email has not been authorized. Please check your inbox and try again.';
  static const String passwordResetEmailNotRegisteredTitle =
      'Password Reset Email Not Registered';
  static const String passwordResetEmailNotRegisteredMsg =
      'The password reset email is not registered. Please check your inbox and try again.';
  static const String passwordResetEmailNotActiveTitle =
      'Password Reset Email Not Active';
  static const String passwordResetEmailNotActiveMsg =
      'The password reset email is not active. Please check your inbox and try again.';
  static const String passwordResetEmailNotEnabledTitle =
      'Password Reset Email Not Enabled';
  static const String passwordResetEmailNotEnabledMsg =
      'The password reset email is not enabled. Please check your inbox and try again.';
  static const String passwordResetEmailNotAvailableTitle =
      'Password Reset Email Not Available';
  static const String passwordResetEmailNotAvailableMsg =
      'The password reset email is not available. Please check your inbox and try again.';
  static const String passwordResetEmailNotSupportedTitle =
      'Password Reset Email Not Supported';
  static const String passwordResetEmailNotSupportedMsg =
      'The password reset email is not supported. Please check your inbox and try again.';
  static const String passwordResetEmailNotValidTitle =
      'Password Reset Email Not Valid';
  static const String passwordResetEmailNotValidMsg =
      'The password reset email is not valid. Please check your inbox and try again.';
}
