--!strict
-- Session locking for player data, so two servers never own the same
-- profile (the classic rejoin-duplication bug). Saved records look like
-- { format = 2, profile = data, session = { job, at }? }; older saves were
-- the bare profile. Pure, so it is unit-tested.

export type Session = { job: string, at: number }

local SessionLock = {}

-- (profile, session) from a stored record of either format.
function SessionLock.unwrap(record: any): (any, Session?)
	if type(record) ~= "table" then
		return nil, nil
	end
	if record.format == 2 then
		return record.profile, record.session
	end
	return record, nil
end

function SessionLock.wrap(profile: any, session: Session?): any
	return { format = 2, profile = profile, session = session }
end

-- Another live server holds this profile (its lock was refreshed recently).
function SessionLock.heldByOther(session: Session?, jobId: string, now: number, lockSeconds: number): boolean
	return session ~= nil and session.job ~= jobId and now - session.at < lockSeconds
end

-- Saving is only safe while the lock is still ours (or nobody's).
function SessionLock.canSave(session: Session?, jobId: string): boolean
	return session == nil or session.job == jobId
end

return SessionLock
