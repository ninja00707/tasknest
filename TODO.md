# Sub-Ticket Permission Fix - TODO (COMPLETED)

## ✅ Step 1: Fix `ChildTicketModel` model (ticketmodel.dart)
- Added `closedAt` and `reopenCount` fields
- Implemented `canReopenBy()` for creator-only reopen logic (max 1 reopen, 48h window)

## ✅ Step 2: Fix `ticket_action.dart` permissions
- **Button #3 (Mark Completed)**: Sub-ticket → `isResolver` only; Master → `isCreator || isCeo` only
- **Button #4 (Finalize & Close)**: Changed to `isCreator || isCeo` for ALL tickets (was `isResolver` for sub-tickets)
- Reopen button: Works via `canReopenBy()` now properly implemented for ChildTicketModel

## ✅ Step 3: Fix backend `ticket.service.js` updateStatus()
- Sub-ticket close: Changed from `isResolver` to `isCreator || isCeo`

## ✅ Step 4: Fix backend socket notifications for department visibility
- `socketHelper.js`: Added department-room (`dept_${assignedDeptId}`) broadcast for all events
- Added creator department room broadcast as well
- Frontend `socket_service.dart`: Added extra headers for department context

