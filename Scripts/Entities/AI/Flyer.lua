Script.ReloadScript("Scripts/Entities/AI/Flyer_x.lua");

CreateActor(Flyer_x);
Flyer = CreateAI(Flyer_x)
Flyer:Expose();
