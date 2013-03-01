Boid = {
  type = "Boid",

  Client = {},
  Server = {},
}

----------------------------------------------------------------------------------------------------
function Boid.Client:OnHit(hit)
	if (self.flock_entity and not self.bWasHit) then
		self.bWasHit = 1;
		Boids.OnBoidHit( self.flock_entity,self,hit );	
	end
end

----------------------------------------------------------------------------------------------------
function Boid.Server:OnHit(hit)
	if (self.flock_entity and not self.bWasHit) then
		self.bWasHit = 1;
		Boids.OnBoidHit( self.flock_entity,self,hit );	
	end
end

function Boid:OnUsed(user, idx)
	if idx == 2 then
		--BroadcastEvent(self, "Used")
	elseif (user and user.GrabObject) then
		--System.Log( "Grab Boid" );
	end
end

