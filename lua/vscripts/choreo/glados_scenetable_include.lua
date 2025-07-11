﻿-- ********************************************************************************************
-- Scene table converted manually using Regex and post-cleanup work
-- ********************************************************************************************
SceneTable = SceneTable or {}
-- PreHub01                                
-- AirSupplySuccess
-- Well done. In the event that oxygen is no longer available in the Enrichment Center, an auxiliary air supply will be provided to you by an Aperture Science Test Associate, if one exists.
SceneTable["PreHub01AirSupplySuccess01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub56.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- BoldPersistent
-- Excellent. The Enrichment Center reminds you that bold, persistent experimentation is the hallmark of good science.
SceneTable["PreHub01BoldPersistent01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub55.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- BoxDropperEntry
-- This next test is very dangerous. To help you remain tranquil in the face of almost certain death, smooth jazz will be deployed in three. Two. One. <SMOOTH JAZZ>
SceneTable["PreHub01BoxDropperEntry01"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/PreHub42.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "announcer",
    noDingOff = true
}

if curMapName == "sp_a1_intro1" then
    -- Chamber01Entry
    -- Cube- and button-based testing remains an important tool for science, even in a dire emergency.
    SceneTable["PreHub01Chamber01Entry01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub11.vcd"),
        postdelay = 0.5,
        next = "PreHub01Chamber01Entry02",
        char = "announcer",
        predelay = 0.25
    }

    -- If cube- and button-based testing caused this emergency, don't worry. The odds of this happening twice are very slim.
    SceneTable["PreHub01Chamber01Entry02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub12.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro1_fizzler_test()",
                delay = 0.0
            }
        }
    }
end

-- Chamber01GrillSpeech
-- You have just passed through an Aperture Science Material Emancipation Grill, which erases most Aperture Science equipment that touches it.
SceneTable["PreHub01Chamber01GrillSpeech01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub26.vcd"),
    postdelay = 0.4,
    next = "PreHub01Chamber01GrillSpeech02",
    char = "glados"
}

-- If you feel liquid running down your neck, relax, lie on your back, and apply immediate pressure to your temples.
SceneTable["PreHub01Chamber01GrillSpeech02"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub27.vcd"),
    postdelay = 0.4,
    next = "PreHub01Chamber01GrillSpeech03",
    char = "glados"
}

-- You are simply experiencing a rare reaction, in which the Material Emancipation Grill may have erased the ear tubes inside your head.
SceneTable["PreHub01Chamber01GrillSpeech03"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub28.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Chamber01Success
-- Good!
SceneTable["PreHub01Chamber01Success01"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/Good01.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "announcer"
}

-- Chamber02Entry
-- Due to events beyond our control, some testing environments may contain flood damage or ongoing tribal warfare resulting from the collapse of civilization.
SceneTable["PreHub01Chamber02Entry01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub15.vcd"),
    postdelay = 0.4,
    next = "PreHub01Chamber02Entry02",
    char = "glados"
}

-- If groups of hunter-gatherers appear to have made this - or any - test chamber their home, DO NOT AGITATE THEM. Test through them.
SceneTable["PreHub01Chamber02Entry02"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub16.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Chamber02Success
-- You performed this test better than anyone on record. This is a pre-recorded message.
SceneTable["PreHub01Chamber02Success01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub14.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Chamber03Entry
-- Because this message is prerecorded, the Enrichment Center has no way of knowing if whatever government remains offers any sort of Cattle Tuberculosis Testing Credit for taxes.
SceneTable["PreHub01Chamber03Entry01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub29.vcd"),
    postdelay = 0.8,
    next = "PreHub01Chamber03Entry02",
    char = "glados"
}

-- In the event that it does, this next test involves exposure to cattle tuberculosis. Good luck!
SceneTable["PreHub01Chamber03Entry02"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub30.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Chamber04Entry
-- This next test applies the principles of momentum to movement through portals. If the laws of physics no longer apply in the future, God help you.
SceneTable["PreHub01Chamber04Entry01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub34.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Chamber04Success
-- Congratulations! This pre-recorded congratulations assumes you have mastered the principles of portal momentum.
SceneTable["PreHub01Chamber04Success01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub35.vcd"),
    postdelay = 0.4,
    next = "PreHub01Chamber04Success02",
    char = "glados"
}

-- If you have, in fact, not, you are encouraged to take a moment to reflect on your failure before proceeding into the next chamber.
SceneTable["PreHub01Chamber04Success02"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub36.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- Compliment01
-- Very impressive! Because this message is prerecorded, any comments we may make about your success are speculation on our part. Please disregard any undeserved compliments.
SceneTable["PreHub01Compliment0101"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub32.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- DualButtonOnePortalEntry
-- At the time of this recording, Federal disclosure policies require us to inform you that this next test is probably lethal and to redirect you to a safer test environment.
SceneTable["PreHub01DualButtonOnePortalEntry01"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/PreHub43.vcd"),
    postdelay = 0.2,
    next = "PreHub01DualButtonOnePortalEntry02",
    char = "announcer",
    noDingOff = true
}

-- We will attempt to comply with these now non-existent agencies by playing some more smooth jazz. <SMOOTH JAZZ>
SceneTable["PreHub01DualButtonOnePortalEntry02"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/PreHub44.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "announcer",
    noDingOff = true
}

-- DualButtonOnePortalSuccessA
-- Great work! Because this message is prerecorded, any observations related to  your performance are speculation on our part. Please disregard any undeserved compliments.
SceneTable["PreHub01DualButtonOnePortalSuccessA01"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/testchamber09.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "announcer",
    predelay = 0.2
}

-- DualButtonOnePortalSuccessB
-- Well done! The Enrichment Center reminds you that although circumstances may appear bleak, you are not alone. All Aperture Science personality constructs will remain functional in apocalyptic, low power environments of as few as 1.1 volts.
SceneTable["PreHub01DualButtonOnePortalSuccessB01"] = {
    vcd = CreateSceneEntity("scenes/npc/announcer/testchamber03.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "announcer",
    fires = {
        {
            entity = "@transition_script",
            input = "runscriptcode",
            parameter = "TransitionReady()",
            delay = 0.00
        }
    },
    predelay = 0.5
}

-- Meteors
-- In the event that the Enrichment Center is currently being bombarded with fireballs, meteorites, or other objects from space, please avoid unsheltered testing areas wherever a lack of shelter from spa
SceneTable["PreHub01Meteors01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub24.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

if curMapName == "sp_a1_intro2" then
    -- PortalCarouselEntry
    -- If you feel liquid running down your neck, relax, lie on your back, and apply immediate pressure to your temples.
    SceneTable["PreHub01PortalCarouselEntry01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/prehub27.vcd"),
        postdelay = 0.2,
        next = "PreHub01PortalCarouselEntry02",
        char = "announcer",
        predelay = 1.3
    }

    -- You are simply experiencing a rare reaction, in which the Material Emancipation Grill may have emancipated the ear tubes inside your head.
    SceneTable["PreHub01PortalCarouselEntry02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/prehub28.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer"
    }
end

if curMapName == "sp_a1_intro2" then
    -- PortalCarouselSuccess
    -- Good!
    SceneTable["PreHub01PortalCarouselSuccess01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/Good02.vcd"),
        postdelay = 0.2,
        next = "PreHub01PortalCarouselSuccess02",
        char = "announcer"
    }

    -- Because of the technical difficulties we are currently experiencing, your test environment is unsupervised.
    SceneTable["PreHub01PortalCarouselSuccess02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub19.vcd"),
        postdelay = 0.2,
        next = "PreHub01PortalCarouselSuccess03",
        char = "announcer"
    }

    -- Before re-entering a relaxation vault at the conclusion of testing, please take a moment to write down the results of your test. An Aperture Science Reintegration Associate will revive you for an interview when society has been rebuilt.
    SceneTable["PreHub01PortalCarouselSuccess03"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub20.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }
end

if curMapName == "sp_a1_intro1" then
    -- RelaxationVaultIntro
    -- Hello and, again, welcome to the Aperture Science Enrichment Center.
    SceneTable["PreHub01RelaxationVaultIntro01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub06.vcd"),
        postdelay = 0.3,
        next = "PreHub01RelaxationVaultIntro02",
        char = "announcer",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro1_vault_start()",
                delay = 0.0,
                fireatstart = true
            }
        }
    }

    -- We are currently experiencing technical difficulties due to circumstances of potentially apocalyptic significance beyond our control.
    SceneTable["PreHub01RelaxationVaultIntro02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub08.vcd"),
        postdelay = 0.3,
        next = "PreHub01RelaxationVaultIntro03",
        char = "announcer"
    }

    -- However, thanks to Emergency Testing Protocols, testing will continue. These pre-recorded messages will provide instructional and motivational support, so that science can still be done, even in the e
    SceneTable["PreHub01RelaxationVaultIntro03"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub09.vcd"),
        postdelay = 0.5,
        next = "PreHub01RelaxationVaultIntro04",
        char = "announcer"
    }

    -- The portal will open and emergency testing will begin in three. Two. One.
    SceneTable["PreHub01RelaxationVaultIntro04"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/PreHub10.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "GladosRelaxationVaultPowerUp()",
                delay = 0.0
            }
        }
    }
end

-- SafetyDevicesDisabled
-- In order to ensure that sufficient power remains for core testing protocols, all safety devices have been disabled.
SceneTable["PreHub01SafetyDevicesDisabled01"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub47.vcd"),
    postdelay = 0.5,
    next = "PreHub01SafetyDevicesDisabled02",
    char = "glados"
}

-- The Enrichment Center respects your right to have questions or concerns about this policy.
SceneTable["PreHub01SafetyDevicesDisabled02"] = {
    vcd = CreateSceneEntity("scenes/npc/glados/PreHub48.vcd"),
    postdelay = 0.000,
    next = nil,
    char = "glados"
}

-- sp_a2_intro                                       
if curMapName == "sp_a2_intro" then
    -- ClearArms
    -- I'll just move that out of the way for you. This place really is a wreck.
    SceneTable["sp_incinerator_01ClearArms01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_13.vcd"),
        postdelay = 0.4,
        next = "sp_incinerator_01ClearArms02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- But the important thing is you're back. With me. And now I'm onto all your little tricks. So there's nothing to stop us from testing for the rest of your life.
    SceneTable["sp_incinerator_01ClearArms02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found07.vcd"),
        postdelay = 0.1,
        next = "sp_incinerator_01ClearArms03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- After that...who knows? I might take up a hobby. Reanimating the dead, maybe.
    SceneTable["sp_incinerator_01ClearArms03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Elevator
    -- We're a lot alike, you and I. You tested me. I tested you. You killed me. I--oh, no, wait. I guess I HAVEN'T killed you yet. Well. Food for thought.
    SceneTable["sp_incinerator_01Elevator01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_15.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- FirstSpeech
    -- Once testing starts, I'm required by protocol to keep interaction with you to a minimum. Luckily, we haven't started testing yet. This will be our only chance to talk.
    SceneTable["sp_incinerator_01FirstSpeech01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_08.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 4
    }

    -- GotGun
    -- Good. You found the dual portal device. There should be a way back to the testing area up ahead.
    SceneTable["sp_incinerator_01GotGun01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found01.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2
    }

    -- GunRubbleDone
    -- {she moves some debris} there.
    SceneTable["sp_incinerator_01GunRubbleDone01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_05.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Landing
    -- Here we are. The Incinerator Room. Be careful not to trip over any parts of me that didn't get completely burned when you threw them down here.
    SceneTable["sp_incinerator_01Landing01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_01.vcd"),
        postdelay = 0.2,
        next = "sp_incinerator_01Landing02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- The dual portal device should be around here somewhere. Once you find it, we can start testing. Just like old times.
    SceneTable["sp_incinerator_01Landing02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_18.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- MoveGunRubble
    -- Hold on...
    SceneTable["sp_incinerator_01MoveGunRubble01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_04.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        skipifbusy = 1
    }

    -- MovePanel
    -- Here, let me get that for you.
    SceneTable["sp_incinerator_01MovePanel01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_12.vcd"),
        postdelay = 0.5,
        next = "sp_incinerator_01MovePanel02",
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        skipifbusy = 1
    }

    -- Do you know the biggest lesson I learned from what you did? I discovered I have a sort of black box quick save feature. In the event of a catastrophic failure, the last two minutes of my life are preserved for analysis.
    SceneTable["sp_incinerator_01MovePanel02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_09.vcd"),
        postdelay = 0.2,
        next = "sp_incinerator_01MovePanel03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- I was able - well, forced really - to relive you killing me. Again and again. Forever.
    SceneTable["sp_incinerator_01MovePanel03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_10.vcd"),
        postdelay = 0.4,
        next = "sp_incinerator_01MovePanel04",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- You know, if you'd done that to somebody else, they might devote their existences to exacting revenge on you.
    SceneTable["sp_incinerator_01MovePanel04"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found05.vcd"),
        postdelay = 0.3,
        next = "sp_incinerator_01MovePanel05",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Luckily I'm a bigger person than that. I'm happy to put it all behind us and get back to work. After all, we've got a lot to do, and only sixty more years to do it. More or less. I don't have the actuarial tables in front of me.
    SceneTable["sp_incinerator_01MovePanel05"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- NoClearArms
    -- But the important thing is you're back. With me. And now I'm onto all your little tricks. So there's nothing to stop us from testing for the rest of your life.
    SceneTable["sp_incinerator_01NoClearArms01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found07.vcd"),
        postdelay = 0.1,
        next = "sp_incinerator_01NoClearArms02",
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuepredelay = 0.3
    }

    -- After that...who knows? I might take up a hobby. Reanimating the dead, maybe.
    SceneTable["sp_incinerator_01NoClearArms02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- NoMovePanel
    -- Do you know the biggest lesson I learned from what you did? I discovered I have a sort of black box quick save feature. In the event of a catastrophic failure, the last two minutes of my life are preserved for analysis.
    SceneTable["sp_incinerator_01NoMovePanel02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_09.vcd"),
        postdelay = 0.2,
        next = "sp_incinerator_01NoMovePanel03",
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- I was able - well, forced really - to relive you killing me. Again and again. Forever.
    SceneTable["sp_incinerator_01NoMovePanel03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_10.vcd"),
        postdelay = 0.4,
        next = "sp_incinerator_01NoMovePanel04",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- You know, if you'd done that to somebody else, they might devote their existences to exacting revenge on you.
    SceneTable["sp_incinerator_01NoMovePanel04"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found05.vcd"),
        postdelay = 0.3,
        next = "sp_incinerator_01NoMovePanel05",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Luckily I'm a bigger person than that. I'm happy to put it all behind us and get back to work. After all, we've got a lot to do, and only sixty more years to do it. More or less. I don't have the actuarial tables in front of me.
    SceneTable["sp_incinerator_01NoMovePanel05"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_intro1_found06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- SecondSpeech
    -- Do you know the biggest lesson I learned from what you did? I discovered I have a sort of black box quick save feature. In the event of a catastrophic failure, the last two minutes of my life are preserved for analysis.
    SceneTable["sp_incinerator_01SecondSpeech01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_09.vcd"),
        postdelay = 0.5,
        next = "sp_incinerator_01SecondSpeech02",
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- I was able - well, forced really - to relive you killing me. Again and again. Forever.
    SceneTable["sp_incinerator_01SecondSpeech02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_10.vcd"),
        postdelay = 0.5,
        next = "sp_incinerator_01SecondSpeech03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Fifty thousand years is a lot of time to think. About me. About you. {slight pause} We were doing so well together.
    SceneTable["sp_incinerator_01SecondSpeech03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_11.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- SeeGun
    -- There it is.
    SceneTable["sp_incinerator_01SeeGun01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_incinerator_01_03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2
    }
end

-- sp_a2_laser_intro                                 
if curMapName == "sp_a2_laser_intro" then
    -- End
    -- Not bad. I forgot how good you are at this. You should pace yourself, though. We have A LOT of tests to do.
    SceneTable["sp_laser_redirect_introEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_laser_intro_ending02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- Sorry about the mess. I've really let the place go since you killed me. Thanks for that, by the way.
    SceneTable["sp_laser_redirect_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_redirect_intro_entry01.vcd"),
        postdelay = -6.05,
        next = "sp_laser_redirect_introStart02",
        char = "glados"
    }

    -- Sarcasm Self Test complete.
    SceneTable["sp_laser_redirect_introStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sarcasmcore01.vcd"),
        postdelay = 0.000,
        next = "sp_laser_redirect_introStart03",
        char = "announcerglados",
        talkover = true
    }

    -- Oh, good. That's back online. I'll start getting everything else working while you perform this first, simple test.
    SceneTable["sp_laser_redirect_introStart03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_redirect_intro_entry02.vcd"),
        postdelay = 0.000,
        next = "sp_laser_redirect_introStart04",
        char = "glados"
    }

    -- Which involves deadly lasers and how test subjects react when locked in a room with deadly lasers.
    SceneTable["sp_laser_redirect_introStart04"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_redirect_intro_entry03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_laser_stairs                                
if curMapName == "sp_a2_laser_stairs" then
    -- End
    -- Well done. Here come the test results: You are a horrible person. I'm serious, that's what it says: A horrible person. We weren't even testing for that.
    SceneTable["sp_laser_stairsEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_powered_lift_completion02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- This next test involves discouragement redirection cubes. I'd just finished building them before you had your, well, episode. So now we'll both get to see how they work.
    SceneTable["sp_laser_stairsStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_laser_stairs_intro02.vcd"),
        postdelay = 0.3,
        next = "sp_laser_stairsStart02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- There should be one in the corner.
    SceneTable["sp_laser_stairsStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_laser_stairs_intro03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_dual_lasers                                 
if curMapName == "sp_a2_dual_lasers" then
    -- End
    -- Congratulations. Not on the test.
    SceneTable["sp_laser_dual_lasersEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_redirect_intro_completion01.vcd"),
        postdelay = 0.1,
        next = "sp_laser_dual_lasersEnd03",
        char = "glados"
    }

    -- Most people emerge from suspension terribly undernourished. I want to congratulate you on beating the odds and somehow managing to put on a few pounds.
    SceneTable["sp_laser_dual_lasersEnd03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_redirect_intro_completion03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- Don't let that "horrible person" thing discourage you. It's just a data point. If it makes you feel any better, science has now validated your birth mother's decision to abandon you on a doorstep.
    SceneTable["sp_laser_dual_lasersStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_dual_lasers_intro01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        predelay = 1.0
    }
end

-- sp_laser_powered_lift                   
if curMapName == "sp_laser_powered_lift" then
    -- End
    -- I have the results of the last chamber: You are a horrible person. I'm serious, that's what it says: A horrible person. We weren't even testing for that.
    SceneTable["sp_laser_powered_liftEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_powered_lift_completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- This next test may result in your death. If you want to know what that's like, think back to that time you killed me, and substitute yourself for me.
    SceneTable["sp_laser_powered_liftStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_powered_lift_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_laser_over_goo                              
if curMapName == "sp_a2_laser_over_goo" then
    -- End
    -- I'll give you credit: I guess you ARE listening to me. But for the record: You don't have to go THAT slowly.
    SceneTable["sp_laser_over_gooEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_over_goo_completion01.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "glados",
        noDingOff = true
    }

    -- Start
    -- One moment.
    SceneTable["sp_laser_over_gooStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laser_over_goo_entry01.vcd"),
        postdelay = 3,
        next = "sp_laser_over_gooStart02",
        char = "glados",
        predelay = 2
    }

    -- You're navigating these test chambers faster than I can build them. So feel free to slow down and... do whatever it is you do when you're not destroying this facility.
    SceneTable["sp_laser_over_gooStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_laser_over_goo_intro01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Waddle
    -- Waddle over to the elevator and we'll continue the testing.
    SceneTable["sp_laser_over_gooWaddle01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc12.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        noDingOn = true,
        predelay = 0.2,
        queue = 1,
        queuetimeout = 3
    }
end

-- sp_a2_catapult_intro                              
if curMapName == "sp_a2_catapult_intro" then
    -- End
    -- Here's an interesting fact: you're not breathing real air. It's too expensive to pump this far down. We just take carbon dioxide out of a room, freshen it up a little, and pump it back in. So you'll be breathing the same room full of air for the rest of
    SceneTable["sp_catapult_introEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_catapult01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- This next test involves the Aperture Science Aerial Faith Plate. It was part of an initiative to investigate how well test subjects could solve problems when they were catapulted into space. Results were highly informative: They could not. Good luck!
    SceneTable["sp_catapult_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/faith_plate_intro01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_trust_fling                                 
if curMapName == "sp_a2_trust_fling" then
    -- ElevatorStop
    -- So. Was there anything you wanted to apologize to ME for?
    SceneTable["sp_trust_flingElevatorStop01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/lift_interlude01.vcd"),
        postdelay = 2.0,
        next = "sp_trust_flingElevatorStop02",
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_stop_elevator",
                input = "Trigger",
                parameter = "",
                delay = 0.0
            }
        },
        queue = 1
    }

    -- Anything? Take your time.
    SceneTable["sp_trust_flingElevatorStop02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc15.vcd"),
        postdelay = 2.0,
        next = "sp_trust_flingElevatorStop03",
        char = "glados"
    }

    -- Okay, fine. I'll ask you again in a few decades.
    SceneTable["sp_trust_flingElevatorStop03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc16.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_start_elevator",
                input = "Trigger",
                parameter = "",
                delay = 0.5,
                fireatstart = true
            },
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 1.5
            }
        }
    }

    -- End
    -- Remember before when I was talking about smelly garbage standing around being useless? That was a metaphor. I was actually talking about you. And I'm sorry. You didn't react at the time, so I was worried it sailed right over your head. Which would have
    SceneTable["sp_trust_flingEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_trust_fling06.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Flinged
    -- Did you know I discovered a way to eradicate poverty? But then you KILLED me. So that's gone.
    SceneTable["sp_trust_flingFlinged01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc02.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "glados"
    }

    -- Start
    -- Let's see what the next test is. Oh. Advanced Aerial Faith Plates.
    SceneTable["sp_trust_flingStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_intro_completion01.vcd"),
        postdelay = 0.2,
        next = "sp_trust_flingStart02",
        char = "glados",
        predelay = 1.0
    }

    -- Well. Have fun soaring through the air without a care in the world.
    SceneTable["sp_trust_flingStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_trust_fling_entry01.vcd"),
        postdelay = 0.2,
        next = "sp_trust_flingStart03",
        char = "glados"
    }

    -- *I* have to go to the wing that was made entirely of glass and pick up fifteen acres of broken glass. By myself.
    SceneTable["sp_trust_flingStart03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_trust_fling_entry02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_unassisted_angle_fling               
if curMapName == "sp_unassisted_angle_fling" then
    -- Start
    -- This next test... {boom!} ..is... {BOOM!} dangerous I'llberightback.
    SceneTable["sp_unassisted_angle_flingStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_unassisted_angle_fling_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_hole_in_the_sky                      
if curMapName == "sp_hole_in_the_sky" then
    -- End
    -- Well done. You know, when I woke up and saw the state of the labs, I started to wonder if there was any point to going on. I came THAT close to just giving up and letting you go.
    SceneTable["sp_hole_in_the_skyEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_hole_in_the_sky_completion01.vcd"),
        postdelay = 0.5,
        next = "sp_hole_in_the_skyEnd02",
        char = "glados"
    }

    -- But now, looking around, seeing Aperture restored to its former glory? You don't have to worry about leaving EVER again. I mean that.
    SceneTable["sp_hole_in_the_skyEnd02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_hole_in_the_sky_completion02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- Federal regulations require me to warn you that this next test chamber... is looking pretty good.
    SceneTable["sp_hole_in_the_skyStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_hole_in_the_sky_entry01.vcd"),
        postdelay = 0.2,
        next = "sp_hole_in_the_skyStart02",
        char = "glados"
    }

    -- That's right. Drink it in. You could eat off those wall panels.
    SceneTable["sp_hole_in_the_skyStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_hole_in_the_sky_entry02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_bridge_intro                                
if curMapName == "sp_a2_bridge_intro" then
    -- Elevator
    -- Say. Remember when we cleared the air back there? Is there... anything you want to say to me? {beat} Anything?
    SceneTable["sp_bridge_introElevator01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_bridge_intro_completion02.vcd"),
        postdelay = 1.5,
        next = "sp_bridge_introElevator02",
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_stop_elevator",
                input = "Trigger",
                parameter = "",
                delay = 3.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on, I'll stop the elevator. {beat} Anything? {beat} Take your time...
    SceneTable["sp_bridge_introElevator02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_bridge_intro_completion03.vcd"),
        postdelay = 1.5,
        next = "sp_bridge_introElevator03",
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_start_elevator",
                input = "Trigger",
                parameter = "",
                delay = 1.5
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- {beat, elevator starts up again}Well... I'll be here during the whole next test.
    SceneTable["sp_bridge_introElevator03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_bridge_intro_completion04.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- End
    -- Excellent! You're a predator and these tests are your prey. Speaking of which, I was researching sharks for an upcoming test. Do you know who else murders people who are only trying to help them?
    SceneTable["sp_bridge_introEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bridge_intro03.vcd"),
        postdelay = 0.2,
        next = "sp_bridge_introEnd02",
        char = "glados"
    }

    -- Did you guess "sharks"? Because that's wrong. The correct answer is "nobody." Nobody but you is that pointlessly cruel.
    SceneTable["sp_bridge_introEnd02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bridge_intro04.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- These bridges are made from natural light that I pump in from the surface. If you rubbed your cheek on one, it would be like standing outside wit  h the sun shining on your face. It would also set your hair on fire, so don't actually do it.
    SceneTable["sp_bridge_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bridge_intro01.vcd"),
        postdelay = 2,
        next = nil,
        char = "glados"
    }
end

-- sp_shoot_through_wall                   
if curMapName == "sp_shoot_through_wall" then
    -- End
    -- Did my hint help? It did, didn't it? You know, if any of our supervisors had been immune to neurotoxin, they'd be FURIOUS with us right now.
    SceneTable["sp_shoot_through_wallEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_shoot_through_wall_completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Start
    -- You know, I'm not supposed to do this, but... you can shoot SOMETHING... through the blue bridges.
    SceneTable["sp_shoot_through_wallStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_shoot_through_wall_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_bridge_the_gap                              
if curMapName == "sp_a2_bridge_the_gap" then
    -- DoorBroken
    -- Perfect, the door's malfunctioning. I guess somebody's going to have to repair it. {beat} No, it's okay, I'll do that too. I'll be right back. Don't touch anything.
    SceneTable["sp_bridge_the_gapDoorBroken01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bridge_the_gap02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "spherebot_train_1_chassis_1",
                input = "StartForward",
                parameter = "",
                delay = 3
            }
        },
        predelay = 0.2,
        queue = 1
    }

    -- End
    -- Well done. In fact, you did so well, I'm going to note this on your file, in the commendations section. Oh, there's lots of room here. "Did.... well." "Enough."
    SceneTable["sp_bridge_the_gapEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc19.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- HeyUpHere
    -- Hey! Hey! Up here!
    SceneTable["sp_bridge_the_gapHeyUpHere01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_fling01.vcd"),
        postdelay = 0.2,
        next = "sp_bridge_the_gapHeyUpHere02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I found some bird eggs up here. Just dropped 'em into the door mechanism.  Shut it right down. I--AGH!
    SceneTable["sp_bridge_the_gapHeyUpHere02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_flingAlt07.vcd"),
        postdelay = 0.1,
        next = "sp_bridge_the_gapHeyUpHere03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BIRD BIRD BIRD BIRD
    SceneTable["sp_bridge_the_gapHeyUpHere03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_flingAlt02.vcd"),
        postdelay = 0.6,
        next = "sp_bridge_the_gapHeyUpHere04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- {out of breath} Okay. That's probably the bird, isn't it? That laid the eggs! Livid!
    SceneTable["sp_bridge_the_gapHeyUpHere04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_flingAlt08.vcd"),
        postdelay = 0.3,
        next = "sp_bridge_the_gapHeyUpHere05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Anyway, look, the point is we're gonna break out of here, alright? But we can't do it yet. Look for me fifteen chambers ahead.
    SceneTable["sp_bridge_the_gapHeyUpHere05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_fling03.vcd"),
        postdelay = 0.1,
        next = "sp_bridge_the_gapHeyUpHere06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Here she comes! Just play along! RememberFifteenChambers!
    SceneTable["sp_bridge_the_gapHeyUpHere06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_trust_fling04.vcd"),
        postdelay = 1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "trick_door_open_relay",
                input = "Trigger",
                parameter = "",
                delay = 3.3,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Leave
    -- I went and spoke with the door mainframe. Let's just say he won't be... well, living anymore. Anyway, back to testing.
    SceneTable["sp_bridge_the_gapLeave01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_entryTwo01.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "glados"
    }

    -- Start
    -- Good news. I figured out what to do with all the money I save recycling your one roomful of air. When you die, I'm going to laminate your skeleton and pose you in the lobby. That way future generations can learn from you how not to have your unfortunate
    SceneTable["sp_bridge_the_gapStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bridge_the_gap01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        predelay = 1.0
    }
end

-- sp_sphere_2nd_encounter                 
if curMapName == "sp_sphere_2nd_encounter" then
    -- DoorBreak
    -- Ohhhh. Another door malfunction? I'm going to take care of this once and for all. Stay here, I'll be back in a while.
    SceneTable["sp_sphere_2nd_encounterDoorBreak01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_malfunction01.vcd"),
        postdelay = 0.5,
        next = "sp_sphere_2nd_encounterDoorBreak02",
        char = "glados",
        queue = 1
    }

    -- Miss you!
    SceneTable["sp_sphere_2nd_encounterDoorBreak02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_malfunction02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- End
    -- You really are doing great... Chell.
    SceneTable["sp_sphere_2nd_encounterEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Meetup
    -- I went and spoke with the door mainframe. Let's just say he won't be... well, living anymore. Anyway, back to testing.
    SceneTable["sp_sphere_2nd_encounterMeetup01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_entryTwo01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Start
    -- I shouldn't spoil this, but... remember how I'm going to live forever, but you're going to be dead in sixty years? You know how excruciating it is when someone removes all of your bone marrow? Well, what if after I did that, I put something back IN
    SceneTable["sp_sphere_2nd_encounterStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_sphere_2nd_encounter_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_turret_intro                         
if curMapName == "sp_turret_intro" then
    -- Start
    -- I wouldn't have warned you about this before, back when we hated each other. But those turrets are firing real bullets. So look out. I'd hate for something tragic to happen to you before I extract all your bone marrow.
    SceneTable["sp_turret_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_turret_intro_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_turret_intro                                
if curMapName == "sp_a2_turret_intro" then
    -- Start
    -- This next test involves turrets. You remember them, right? They're the pale spherical things that are full of bullets. Oh wait. That's you in five seconds. Good luck.
    SceneTable["sp_turret_training_advancedStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/turret_intro01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        predelay = 1.5
    }
end

-- sp_a2_turret_blocker                              
if curMapName == "sp_a2_turret_blocker" then
    -- End
    -- I've been going through the list of test subjects in cryogenic storage. I managed to find two with your last name. A man and a woman. So that's interesting. It's a small world.
    SceneTable["sp_turret_blocker_introEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc30.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- That jumpsuit you're wearing looks stupid. {sounds of page flipping} That's not me talking, it's right here in your file. On other people it looks fine, but right here a scientist has noted that on you it looks "stupid."
    SceneTable["sp_turret_blocker_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_turret_intro01.vcd"),
        postdelay = 0.000,
        next = "sp_turret_blocker_introStart02",
        char = "glados"
    }

    -- Well, what does a neck-bearded old engineer know about fashion? He probably - Oh, wait. It's a she. Still, - oh wait, it says she has a medical degree. In fashion! From France!
    SceneTable["sp_turret_blocker_introStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_turret_intro03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "entry_dialog_completed_rl",
                input = "trigger",
                parameter = "",
                delay = 0.0
            }
        }
    }
end

-- sp_a2_column_blocker                              
if curMapName == "sp_a2_column_blocker" then
    -- ElevatorOw
    -- OW!
    SceneTable["sp_column_blockerElevatorOw01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotow01.vcd"),
        postdelay = 0.2,
        next = "sp_column_blockerElevatorOw02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Just hang in there for five more - What? Jerry, you can't fire me for that! Yes, JERRY -- OR, maybe your prejudiced worksite should have accommodated a nanobot of my size. Thanks for the hate crime, Jer!
    SceneTable["sp_column_blockerElevatorOw02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotow04.vcd"),
        postdelay = 0.2,
        next = "sp_column_blockerElevatorOw03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'll sue you. Sue you if anything. Anyway, look, just hang in there for five more chambers.
    SceneTable["sp_column_blockerElevatorOw03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotow03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ElevatorStart
    -- Hey! How's it going! I talked my way onto the nanobot work crew rebuilding this shaft. They are REALLY small, so -ah - I KNOW, Jerry. No, I'm on BREAK, mate. On a break.
    SceneTable["sp_column_blockerElevatorStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotinto09.vcd"),
        postdelay = 0.1,
        next = "sp_column_blockerElevatorStart02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Anyway, we're really close to busting out. Just hang in there for - OW!
    SceneTable["sp_column_blockerElevatorStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotinto08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- End
    -- I feel awful about that surprise. Tell you what, let's give your parents a call right now. {phone ringing} The birth parents you are trying to reach do not love you. Please hang up. {click. Dial tone}
    SceneTable["sp_column_blockerEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_column_blocker03.vcd"),
        postdelay = 0.1,
        next = "sp_column_blockerEnd02",
        char = "glados"
    }

    -- Oh, that's sad. But impressive. Maybe they worked at the phone company.
    SceneTable["sp_column_blockerEnd02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_column_blocker04.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "glados"
    }

    -- Start
    -- It's healthy for you to have other friends. To look for qualities in other people that I obviously lack.
    SceneTable["sp_column_blockerStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_column_blocker_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_laser_vs_turret                             
if curMapName == "sp_a2_laser_vs_turret" then
    -- End
    -- {hums "For He's A Jolly Good Fellow"}
    SceneTable["sp_laser_vs_turret_introEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc24.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- I have a surprise waiting for you after this next test. Telling you would spoil the surprise, so I'll just give you a hint: it involves meeting two people you haven't seen in a long time.
    SceneTable["sp_laser_vs_turret_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc31.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "glados",
        predelay = 1.8
    }
end

-- sp_a2_laser_relays                                
if curMapName == "sp_a2_laser_relays" then
    -- End
    -- You know how I'm going to live forever, but you're going to be dead in sixty years?  Well, I've been working on a belated birthday present for you. Well. More of a belated birthday medical procedure. Well. Technically, it's a medical EXPERIMENT.
    SceneTable["sp_laser_relaysEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc23.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- To maintain a constant testing cycle, I simulate daylight at all hours and add adrenal vapor to your oxygen supply. So you may be confused about the passage of time. The point is, yesterday was your birthday. I thought you'd want to know.
    SceneTable["sp_laser_relaysStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc21.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        predelay = 2.0
    }
end

-- sp_a2_ring_around_turrets                         
if curMapName == "sp_a2_ring_around_turrets" then
    -- End
    -- I'll bet you think I forgot about your surprise. I didn't. In fact, we're headed to your surprise right now. After all these years. I'm getting choked up just thinking about it.
    SceneTable["sp_ring_around_the_turretsEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc33.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- I'll bet you think I forgot about your surprise. I didn't. In fact, we're headed to your surprise right now. After all these years. I'm getting choked up just thinking about it.
    SceneTable["sp_ring_around_the_turretsStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc33.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_sphere_peek                                 
if curMapName == "sp_a2_sphere_peek" then
    -- BounceOne
    -- Hey! Hey! It's me! I'm okay!
    SceneTable["sp_catapult_fling_sphere_peekBounceOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_catapult_fling_sphere_peek01.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BounceThree
    -- A bloody bird! Right? Couldn't believe it either. And then the bird--
    SceneTable["sp_catapult_fling_sphere_peekBounceThree01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_catapult_fling_sphere_peek03.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BounceTwo
    -- You'll never believe what happened! There I was, just lying there, you thought I was done for, but I wasn't, and what happened was--
    SceneTable["sp_catapult_fling_sphere_peekBounceTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_catapult_fling_sphere_peek02.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- End
    -- Look at you. Sailing through the air majestically. Like an eagle. Piloting a blimp. Anyway, nice job.
    SceneTable["sp_catapult_fling_sphere_peekEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_Completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- FailureOne
    -- Okay, I'm back. The Aerial Faith Plate in here is sending a distress signal.
    SceneTable["sp_catapult_fling_sphere_peekFailureOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failureone01.vcd"),
        postdelay = 0.4,
        next = "sp_catapult_fling_sphere_peekFailureOne02",
        char = "glados",
        talkover = true,
        predelay = 2.5
    }

    -- You broke it, didn't you. {bloooo...}
    SceneTable["sp_catapult_fling_sphere_peekFailureOne02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failureone02.vcd"),
        postdelay = 0.5,
        next = "sp_catapult_fling_sphere_peekFailureOne03",
        char = "glados"
    }

    -- {bloop!} There. Try it now.
    SceneTable["sp_catapult_fling_sphere_peekFailureOne03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failureone03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_fix_catapult",
                input = "Trigger",
                parameter = "",
                delay = 0.20
            }
        }
    }

    -- FailureThree
    -- You seem to have defeated its load-bearing capacity. Well done. I'll just lower the ceiling.
    SceneTable["sp_catapult_fling_sphere_peekFailureThree01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failurethree01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_fix_ceiling",
                input = "Trigger",
                parameter = "",
                delay = 0.0
            }
        },
        talkover = true,
        predelay = 2.5
    }

    -- FailureTwo
    -- Hmm. This Plate must not be calibrated to someone of your... generous... ness. I'll add a few zeros to the maximum weight.
    SceneTable["sp_catapult_fling_sphere_peekFailureTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failuretwo01.vcd"),
        postdelay = 0.0,
        next = "sp_catapult_fling_sphere_peekFailureTwo02",
        char = "glados",
        talkover = true,
        predelay = 2.5
    }

    -- {deet-deet-deet} You look great, by the way. Very healthy.
    SceneTable["sp_catapult_fling_sphere_peekFailureTwo02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failuretwo02.vcd"),
        postdelay = 0.4,
        next = "sp_catapult_fling_sphere_peekFailureTwo03",
        char = "glados"
    }

    -- Try now.
    SceneTable["sp_catapult_fling_sphere_peekFailureTwo03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_catapult_fling_sphere_peek_failuretwo03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@trigger_this_to_fix_catapult",
                input = "Trigger",
                parameter = "",
                delay = 0.2
            }
        }
    }
end

-- sp_a2_turret_tower                                
if curMapName == "sp_a2_turret_tower" then
    -- End
    -- I think these test chambers look even better than they did before. It was easy, really. You just have to look at things objectively, see what you don't need anymore, and trim out the fat.
    SceneTable["sp_turret_towerEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/a2_triple_laser03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }
end

-- sp_paint_jump_trampoline                
if curMapName == "sp_paint_jump_trampoline" then
    -- End
    -- Just so you know, I have to go give a deposition. For an upcoming trial. In case that interests you.
    SceneTable["sp_paint_jump_trampolineEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_trampoline_completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Start
    -- While I was out investigating, I found a fascinating new test element. It's never been used for human testing because, apparently, contact with it causes heart failure. The literature doesn't mention anything about lump-of-coal failure, though, so you
    SceneTable["sp_paint_jump_trampolineStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_trampoline_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_paint_jump_redirect_bomb             
if curMapName == "sp_paint_jump_redirect_bomb" then
    -- End
    -- I thought we could test like we used to. But I'm discovering things about you that I never saw before. We... we can't ever go back to the way it was, can we?
    SceneTable["sp_paint_jump_redirect_bombEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_redirect_bomb_completion01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Start
    -- You can't keep going like this forever, you know. I'm GOING to find out what you're doing. Out there. Where I can't see you. I'll know. All I need is proof.
    SceneTable["sp_paint_jump_redirect_bombStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_redirect_bomb_entry01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_paint_jump_wall_jumps                
if curMapName == "sp_paint_jump_wall_jumps" then
    -- Start
    -- Did you know that people with guilty consciences are more easily startled by loud noi-{foghorn}
    SceneTable["sp_paint_jump_wall_jumpsStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_wall_jumps01.vcd"),
        postdelay = 0.0,
        next = "sp_paint_jump_wall_jumpsStart02",
        char = "glados"
    }

    -- I'm sorry, I don't know why that went off. Anyway, just an interesting science fact.
    SceneTable["sp_paint_jump_wall_jumpsStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_wall_jumps02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_paint_jump_wall_jumps_gap            
if curMapName == "sp_paint_jump_wall_jumps_gap" then
    -- Start
    -- I'm going to be honest with you now. Not fake honest like before, but real honest, like you're incapable of. I know you're up to something.
    SceneTable["sp_paint_jump_wall_jumps_gapStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_turret_islands01.vcd"),
        postdelay = 0.2,
        next = "sp_paint_jump_wall_jumps_gapStart02",
        char = "glados"
    }

    -- And as soon as I can PROVE it, the laws of robotics allow me to terminate you for being a liar.
    SceneTable["sp_paint_jump_wall_jumps_gapStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_turret_islands02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_climb_for_los                        
if curMapName == "sp_climb_for_los" then
    -- End
    -- Oh. You survived. That's interesting. I guess I should have factored in your weight. By the way, I'm not sure if I've mentioned it, but you've really gained a lot of weight.
    SceneTable["sp_climb_for_losEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_box_over_goo01.vcd"),
        postdelay = 0.1,
        next = "sp_climb_for_losEnd02",
        char = "glados"
    }

    -- One of these times you'll be so fat that you'll jump, and you'll just drop like a stone. Into acid, probably. Like a potato into a deep fryer.
    SceneTable["sp_climb_for_losEnd02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_box_over_goo04.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_angled_bridge                        
if curMapName == "sp_angled_bridge" then
    -- Start
    -- Per our last conversation: You're also ugly. I'm looking at your file right now, and it mentions that more than once.
    SceneTable["sp_angled_bridgeStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_laserfield_intro01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a4_stop_the_box                                
-- sp_turret_islands                       
if curMapName == "sp_turret_islands" then
    -- Start
    -- Why do I hate you so much? You ever wonder that? I'm brilliant. I’m not bragging. It's an objective fact. I'm the most massive collection of wisdom and raw computational power that’s ever existed.
    SceneTable["sp_turret_islandsStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/EvilAgainSamples03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_catapult_course                      
if curMapName == "sp_catapult_course" then
    -- End
    -- You never considered that maybe I tested you to give the endless hours of your pointless existence some structure and meaning. Maybe to help you concentrate, so just maybe you’d think of something more worthwhile to do with your sorry life.
    SceneTable["sp_catapult_courseEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/EvilAgainSamples05.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- Start
    -- You're angry. I know it. "She tested me too hard. She’s unfair.” Boo hoo. I don't suppose you ever stopped whining long enough to reflect on your own shortcomings, though, did you?
    SceneTable["sp_catapult_courseStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/EvilAgainSamples04.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_box_over_goo                         
-- sp_laserfield_intro                     
if curMapName == "sp_laserfield_intro" then
    -- Start
    -- Did you ever stop to think that eventually there’s a point where your name gets mentioned for the very last time. Well, here it is: I’m going to kill you, Chell.
    SceneTable["sp_laserfield_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/EvilAgainSamples01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_bts1                                        
if curMapName == "sp_a2_bts1" then
    -- JailbreakAhh
    -- ahhh!
    SceneTable["sp_sabotage_jailbreakJailbreakAhh01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun05.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakAlmostThere
    -- There's the entrance to maintenance area!
    SceneTable["sp_sabotage_jailbreakJailbreakAlmostThere01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun07.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_jailbreakJailbreakAlmostThere02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.5
    }

    -- Hurry! Come on!
    SceneTable["sp_sabotage_jailbreakJailbreakAlmostThere02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun08.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakBridgeDisappear
    -- Ow.
    SceneTable["sp_sabotage_jailbreakJailbreakBridgeDisappear01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/stairbouncepain01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "WheatleyGoGoGoNag()",
                delay = 2.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakClosing
    -- RUN! Come on! I'm closing the doors!
    SceneTable["sp_sabotage_jailbreakJailbreakClosing01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor06.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_jailbreakJailbreakClosing02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We're not safe yet.
    SceneTable["sp_sabotage_jailbreakJailbreakClosing02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor07.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakClosing03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We're not safe yet. Quick! Follow the walkway.
    SceneTable["sp_sabotage_jailbreakJailbreakClosing03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor08.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakDestroying
    -- She's bringin' the whole place down!
    SceneTable["sp_sabotage_jailbreakJailbreakDestroying01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun10.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_jailbreakJailbreakDestroying02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 2
    }

    -- Run! Quick!
    SceneTable["sp_sabotage_jailbreakJailbreakDestroying02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun11.vcd"),
        postdelay = 2.0,
        next = "sp_sabotage_jailbreakJailbreakDestroying03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hurry! This way!
    SceneTable["sp_sabotage_jailbreakJailbreakDestroying03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakDoorClosing
    -- RUN! Come on! I'm closing the doors!
    SceneTable["sp_sabotage_jailbreakJailbreakDoorClosing01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakneardoor06.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_jailbreakJailbreakDoorClosing02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 1.7,
        queuepredelay = 0.2
    }

    -- Allright, quick recap: We are escaping! This is us escaping. So keep running!
    SceneTable["sp_sabotage_jailbreakJailbreakDoorClosing02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts1a01.vcd"),
        postdelay = 0.4,
        next = "sp_sabotage_jailbreakJailbreakDoorClosing03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Quick word about the future plans.
    SceneTable["sp_sabotage_jailbreakJailbreakDoorClosing03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts1a02.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakDoorClosing04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We are going to shut down her turret production line, turn off her neurotoxin, and then confront her.
    SceneTable["sp_sabotage_jailbreakJailbreakDoorClosing04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts1a03.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakDoorClosing05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Again, though, for the moment: RUN!
    SceneTable["sp_sabotage_jailbreakJailbreakDoorClosing05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts1a04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "WheatleyGoGoGoNag()",
                delay = 2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakElevatorStart
    -- Ohhhhhh, we just made it! That was close.
    SceneTable["sp_sabotage_jailbreakJailbreakElevatorStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakFakeFail
    -- Hey hey!
    SceneTable["sp_sabotage_jailbreakJailbreakFakeFail01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakfaketest06.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakFakeFail02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Whoah whoah, what ya doing?
    SceneTable["sp_sabotage_jailbreakJailbreakFakeFail02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakfaketest07.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakFakeTest
    -- Before you leave, why don't we do one more test? For old time's sake...
    SceneTable["sp_sabotage_jailbreakJailbreakFakeTest01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak12.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakFakeTest02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- You already did this one. It'll be easy.
    SceneTable["sp_sabotage_jailbreakJailbreakFakeTest02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak13.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakFakeTest03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- How stupid do you think we are?
    SceneTable["sp_sabotage_jailbreakJailbreakFakeTest03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakfaketest04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakGoGoGoNag
    -- Come on! Come on!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens23.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerandom = true,
        idlerepeat = true,
        idleminsecs = 4.000,
        idlemaxsecs = 11.000,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 1
    }

    -- Come on come on come on!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 2
    }

    -- Keep moving! Just keep moving!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens24.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 3
    }

    -- Run, for goodness sake!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens25.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 4
    }

    -- Come on, let's go!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 5
    }

    -- Hurry! This way!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 6
    }

    -- Go! Go go go!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens26.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 7
    }

    -- This way! This way!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 8
    }

    -- Come on! Over here! This way!
    SceneTable["sp_sabotage_jailbreakJailbreakGoGoGoNag09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakgogogonag",
        idleorderingroup = 9
    }

    -- JailbreakGottaGo
    -- She can still see us back here.
    SceneTable["sp_sabotage_jailbreakJailbreakGottaGo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun02.vcd"),
        postdelay = 0.00,
        next = "sp_sabotage_jailbreakJailbreakGottaGo02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We've got to get to the maintenance area.
    SceneTable["sp_sabotage_jailbreakJailbreakGottaGo02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun03.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_jailbreakJailbreakGottaGo03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- She won't be able to touch us there.
    SceneTable["sp_sabotage_jailbreakJailbreakGottaGo03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun04.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakHeadsUp
    -- Watch yer head!
    SceneTable["sp_sabotage_jailbreakJailbreakHeadsUp01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun06.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakHeyLady
    -- Hey, buddy!
    SceneTable["sp_sabotage_jailbreakJailbreakHeyLady01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens01.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakHeyLady02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'm speaking in an accent that is beyond her range of hearing...
    SceneTable["sp_sabotage_jailbreakJailbreakHeyLady02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens07.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakHeyLady03",
        char = "wheatley",
        fires = {
            {
                entity = "@jailbreak_exit_trigger",
                input = "Enable",
                parameter = "",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- I know I'm early, but we have to go right NOW!
    SceneTable["sp_sabotage_jailbreakJailbreakHeyLady03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens05.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakHeyLady04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Walk casually toward my position and we'll go shut her down.
    SceneTable["sp_sabotage_jailbreakJailbreakHeyLady04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakHowStupid
    -- Oh, what? How stupid does she think we are?
    SceneTable["sp_sabotage_jailbreakJailbreakHowStupid01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakICanHearYou
    -- Look - I CAN hear you.
    SceneTable["sp_sabotage_jailbreakJailbreakICanHearYou01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak09.vcd"),
        postdelay = -3.0,
        next = "sp_sabotage_jailbreakJailbreakICanHearYou02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Run! I don't need to do the voice. RUN!
    SceneTable["sp_sabotage_jailbreakJailbreakICanHearYou02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens22.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@jailbreak_1st_wall_1_2_open_logic",
                input = "Trigger",
                parameter = "",
                delay = 1.6,
                fireatstart = true
            },
            {
                entity = "@jailbreak_1st_wall_2_2_open_logic",
                input = "Trigger",
                parameter = "",
                delay = 1.6,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "GladosPlayVcd(499)",
                delay = 1.5
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakJumpDown
    -- jump down to the catwalk!
    SceneTable["sp_sabotage_jailbreakJailbreakJumpDown01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun01.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakKeepOnWalkway
    -- We're not safe yet. Quick! Follow the walkway.
    SceneTable["sp_sabotage_jailbreakJailbreakKeepOnWalkway01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakneardoor08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "WheatleyGoGoGoNag()",
                delay = 1.2
            }
        },
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 6,
        queuepredelay = 0.2
    }

    -- JailbreakLastTestDeer
    -- Wait, where are you going? Where are you going?
    SceneTable["sp_sabotage_jailbreakJailbreakLastTestDeer01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonewhere01.vcd"),
        postdelay = -1.0,
        next = "sp_sabotage_jailbreakJailbreakLastTestDeer02",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, look. There's a deer! You probably can't see it. Get closer.
    SceneTable["sp_sabotage_jailbreakJailbreakLastTestDeer02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreakfaketest05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2
    }

    -- JailbreakLastTestIntro
    -- The irony is that you were almost at the last test.
    SceneTable["sp_sabotage_jailbreakJailbreakLastTestIntro01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreakfaketest01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 1.5
    }

    -- JailbreakLastTestMain
    -- Here it is. Why don't you just do it? Trust me, it's an easier way out than whatever asinine plan your friend came up with.
    SceneTable["sp_sabotage_jailbreakJailbreakLastTestMain01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreakfaketest03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "JailBreakHowStupid()",
                delay = 0.0
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakRunNag
    -- Run!
    SceneTable["sp_sabotage_jailbreakJailbreakRunNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerepeat = true,
        idlerandomonrepeat = true,
        idleminsecs = 2.000,
        idlemaxsecs = 3.000,
        idlegroup = "sp_sabotage_jailbreakjailbreakrunnag",
        idleorderingroup = 1
    }

    -- Come on! Come on!
    SceneTable["sp_sabotage_jailbreakJailbreakRunNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens23.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakrunnag",
        idleorderingroup = 2
    }

    -- Come on come on come on!
    SceneTable["sp_sabotage_jailbreakJailbreakRunNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakrunnag",
        idleorderingroup = 3
    }

    -- Run, for goodness sake!
    SceneTable["sp_sabotage_jailbreakJailbreakRunNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens25.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreakjailbreakrunnag",
        idleorderingroup = 4
    }

    -- JailbreakStart
    -- What's going on? Who turned off the lights.
    SceneTable["sp_sabotage_jailbreakJailbreakStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/Jailbreak10.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }

    -- JailbreakTurrets
    -- Turrets!
    SceneTable["sp_sabotage_jailbreakJailbreakTurrets01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun09.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.5
    }

    -- JailbreakWhoah
    -- Whoa! Hey! Don't fall!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor01.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakWhoah02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Don't listen to him: Jump
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak04.vcd"),
        postdelay = 0.01,
        next = "sp_sabotage_jailbreakJailbreakWhoah03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor02.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakWhoah04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on. Run back the other way! I'll turn the bridges back on!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor03.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakWhoah05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You have to get to the catwalk behind me!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor10.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoah10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- It seems kind of silly to point this out, since you're running around plotting to destroy me. But I think we're done testing.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah10"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak05.vcd"),
        postdelay = 0.6,
        next = "sp_sabotage_jailbreakJailbreakWhoah11",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Do hear that? That's the sound of the neurotoxin emitters emitting neurotoxin.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah11"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak06.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoah15",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Stay casual when I tell you this: I think I smell neurotoxin.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah15"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor11.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoah16",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Look - I CAN hear you.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah16"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak09.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoah17",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh God! Oh, don't need to do that anymore. The jig is up, RUN!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah17"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakDoorOpens17.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_jailbreakJailbreakWhoah18",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- RUN! Come on!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoah18"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakDoorOpens12.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakWhoahAlt
    -- Whoa! Hey! Don't fall!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor01.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Don't listen to him: Jump
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak04.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt03",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor02.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on. Run back the other way! I'll turn the bridges back on!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor03.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- What are you two doing?
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt05"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak11.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt06",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Get to the catwalk behind me, and we'll go shut her down for good.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor09.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt07"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak02.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt10",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- It seems kind of silly to point this out, since you're running around plotting to destroy me. But I think we're done testing.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt10"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak05.vcd"),
        postdelay = 0.6,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt11",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Do hear that? That's the sound of the neurotoxin emitters emitting neurotoxin.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt11"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak06.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt15",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Stay casual when I tell you this: I think I smell neurotoxin.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt15"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakNearDoor11.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt16",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Look - I CAN hear you.
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt16"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/jailbreak09.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt17",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh God! Oh, don't need to do that anymore. The jig is up, RUN!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt17"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakDoorOpens17.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_jailbreakJailbreakWhoahAlt18",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- RUN! Come on!
    SceneTable["sp_sabotage_jailbreakJailbreakWhoahAlt18"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/JailbreakDoorOpens12.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Start
    -- I've got a surprise for you after this next test. Not a fake, tragic surprise like last time. A real surprise, with tragic consequences. And real confetti this time. The good stuff. Our last bag. Part of me's going to miss it, I guess-but at the end of
    SceneTable["sp_sabotage_jailbreakStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_bts1_intro01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        predelay = 1.1
    }
end

-- sp_a2_bts3                                        
if curMapName == "sp_a2_bts3" then
    -- DarknessIntro
    -- Brilliant you made it! Follow me we've still got work to do. At least she can't touch us back here.
    SceneTable["sp_sabotage_darknessDarknessIntro02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour65.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.0
    }

    -- ghoststory
    -- The old caretaker of this place went crazy. Chopped up his whole staff. All robots. They say at night you can still hear the screams. Of their replicas. All of them functionally indistinguishable from the originals. No memory of the incident.
    SceneTable["sp_sabotage_darknessghoststory01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour57.vcd"),
        postdelay = 0.8,
        next = "sp_sabotage_darknessghoststory02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- It sure is dark down here
    SceneTable["sp_sabotage_darknessghoststory02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- smellyhuman01
    -- Here's an interesting story. I almost got a job down here in Manufacturing. Guess who the foreman went with? An exact duplicate of himself. Favoritism. Give me the WORST job, tending to all the smelly humans.
    SceneTable["sp_sabotage_darknesssmellyhuman0101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour58.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_darknesssmellyhuman0102",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- The...um... sorry.. I wouldn't say smelly. Just attending to the humans.
    SceneTable["sp_sabotage_darknesssmellyhuman0102"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour59.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- smellyhuman02
    -- Sorry. That just slipped out. Insensitive.
    SceneTable["sp_sabotage_darknesssmellyhuman0201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour60.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- smellyhuman03
    -- Here's an interesting story. I almost got a job down here in Manufacturing. Guess who the foreman went with? An exact duplicate of himself. Favoritism. Give me the WORST job, tending to all the smelly humans. Sorry. That just slipped out. Insensitive.
    SceneTable["sp_sabotage_darknesssmellyhuman0301"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour71.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "lookat_player_rl",
                input = "Trigger",
                parameter = "",
                delay = 15.000,
                fireatstart = true
            },
            {
                entity = "@enable_fast_swivel",
                input = "Trigger",
                parameter = "",
                delay = 14.00,
                fireatstart = true
            },
            {
                entity = "@disable_fast_swivel",
                input = "Trigger",
                parameter = "",
                delay = 17.00,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- smellyhuman04
    -- Ah. I tell ya. Humans. I just... cherish them. And their... folklore. Colorful.
    SceneTable["sp_sabotage_darknesssmellyhuman0401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour62.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- smellyhuman05
    -- I thought of another great thing about humans. You invented us. Thus giving us the opportunity to let you relax while we invented everything else. We couldn't have done any of that without you. Classy.
    SceneTable["sp_sabotage_darknesssmellyhuman0501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour63.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_darkness_node550
    -- It sure is dark down here
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour07.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node551
    -- This is the turret manufacturing wing. Just past this is the neurotoxin production facility. We find a way to take them both offline, and she’ll be helpless. Which is ideal.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour08.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node552
    -- I'm pretty sure we're going the right way. Pretty sure.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour09.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node553
    -- Allright, the turret factory should be this way. Generally.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55301"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour10.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node555
    -- Oh, careful now.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour11.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node556
    -- Try to jump across.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55601"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour12.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node557
    -- Are you OK?
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55701"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour13.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node558
    -- Are you alive down there?
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55801"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour14.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node559
    -- If you are alive, can you say something. Jump around so I know you are OK?
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node55901"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour15.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node560
    -- There you are!  I was starting to get worried.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour16.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node561
    -- Lets try this again.  Try to make your way across the machinery.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour17.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node562
    -- Lets keep moving. The factory entrance must be around here somewhere.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour18.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node564
    -- Careful...  Careful...
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour19.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node565
    -- Wait. Careful. Let me light this jump for you
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour20.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node567
    -- Okay, this way
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56701"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour22.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node568
    -- No, no, i'm sure it's this way. I'm definitely sure it's this way.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56801"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour23.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node569
    -- Hm.  Lets try this way.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node56901"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour24.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node570
    -- Can you hear that? She has really kicked this place into high gear now.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour25.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node571
    -- This looks dangerous.  I'll hold the light steady.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour26.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node573
    -- Quick, this way!
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57301"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour28.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node574
    -- Nicely Done!
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour29.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node575
    -- Okay, let me light this path for you.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour30.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 1
    }

    -- sp_sabotage_darkness_node577
    -- No, not that way
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node57701"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour32.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node590
    -- We have to split up here for a moment.  Portal up to that passage and i'll see you on the other side.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node59001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour33.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node600
    -- We have to get you out of that room.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node60001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour35.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node601
    -- Can you reach that wall back there?
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node60101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour36.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node602
    -- There's another wall over here
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node60201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour37.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node610
    -- Ah, here it is - the turret factory entrance! We made it.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node61001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour38.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- sp_sabotage_darkness_node611
    -- Right. Well, I’m going to take this rail down the back way.
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node61101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour55.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_darknesssp_sabotage_darkness_node61102",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- See you at the bottom. Good luck!
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node61102"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour56.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_darkness_node620
    -- Be careful!
    SceneTable["sp_sabotage_darknesssp_sabotage_darkness_node62001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour40.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 5
    }

    -- UhOh
    -- What's happening? Yeah. Um. Ok.
    SceneTable["sp_sabotage_darknessUhOh01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour68.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_darknessUhOh02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Okay! Don't move!
    SceneTable["sp_sabotage_darknessUhOh02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour66.vcd"),
        postdelay = 3,
        next = "sp_sabotage_darknessUhOh04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Okay. Allright. I have an idea. But it's bloody dangerous. Hang on.
    SceneTable["sp_sabotage_darknessUhOh04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour67.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_darknessUhOh05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- GAAAA!
    SceneTable["sp_sabotage_darknessUhOh05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sphere_flashlight_tour70.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "sphere_flashlight_turnon_relay",
                input = "trigger",
                parameter = "",
                delay = 0.2,
                fireatstart = true
            },
            {
                entity = "sphere_begin_flashlight_tour_relay",
                input = "trigger",
                parameter = "",
                delay = 5,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_bts4                                        
if curMapName == "sp_a2_bts4" then
    -- BigPotato
    -- It's growing right up into the ceiling. The whole place is probably overrun with potatoes at this point. At least you won't starve...
    SceneTable["sp_sabotage_factoryBigPotato01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_science_fair01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairBusy()",
                delay = 0.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairNotBusy()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- cleanroom
    -- This is a clean room facility, decontaminates can harm the turret redemption process.
    SceneTable["sp_sabotage_factorycleanroom01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory19.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcerglados",
        noDingOff = true,
        noDingOn = true
    }

    -- defectivetesting
    -- Defective Turret testing active.
    SceneTable["sp_sabotage_factorydefectivetesting01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory21.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factorydefectivetesting02",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- Catwalks are safe during defective turret testing.
    SceneTable["sp_sabotage_factorydefectivetesting02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory22.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factorydefectivetesting03",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- Avoid defective defective turrets as they may still be active.
    SceneTable["sp_sabotage_factorydefectivetesting03"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory23.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryAlmostThere
    -- Almost there...
    SceneTable["sp_sabotage_factoryFactoryAlmostThere01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory24.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryControlDoorHackIntro
    -- Right. Hmm. I'm gonna have to hack the door so we can get at it.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryhackone01.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Technical. You'll need to turn around while I do this.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryhackone02.vcd"),
        postdelay = {0.000, 10.000},
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro03",
        char = "wheatley",
        fires = {
            {
                entity = "@wheatley_dont_watch_aisc",
                input = "Enable",
                parameter = "",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Turn around. I'll only be a second. If you don't mind.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts4_turnaroundnags03.vcd"),
        postdelay = {0.000, 10.000},
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Go on, just turn right around. So you're not looking at me.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts4_turnaroundnags02.vcd"),
        postdelay = {0.000, 14.000},
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Just turn around.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts4_turnaroundnags01.vcd"),
        postdelay = {0.000, 14.000},
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Could you turn around? Is that possible?
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts4_turnaroundnags05.vcd"),
        postdelay = {0.000, 14.000},
        next = "sp_sabotage_factoryFactoryControlDoorHackIntro07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Would you mind putting your back towards me? So I can see only your back. And not your face.
    SceneTable["sp_sabotage_factoryFactoryControlDoorHackIntro07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts4_turnaroundnags04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryControlRoomHackSuccess
    -- Done! Hacked!
    SceneTable["sp_sabotage_factoryFactoryControlRoomHackSuccess01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryhackone12.vcd"),
        postdelay = 1.0,
        next = "sp_sabotage_factoryFactoryControlRoomHackSuccess02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.2
    }

    -- Okay, go on, just pull that turret out.
    SceneTable["sp_sabotage_factoryFactoryControlRoomHackSuccess02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretone02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryDefectiveTurretBringOne
    -- What do you have there?
    SceneTable["sp_sabotage_factoryFactoryDefectiveTurretBringOne02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturrettwoback01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryDefectiveTurretBringTwo
    -- Oh no, you've got it, you've got it! Yes! Put him in there! Let's see how this place likes a crap turret.
    SceneTable["sp_sabotage_factoryFactoryDefectiveTurretBringTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturrettwoback08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryEnterScannerWithTurretNoHint
    -- What are you...
    SceneTable["sp_sabotage_factoryFactoryEnterScannerWithTurretNoHint01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturrettwoback10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryFirstTurretPulled
    -- Well, that should do it.
    SceneTable["sp_sabotage_factoryFactoryFirstTurretPulled01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone02.vcd"),
        postdelay = -1.1,
        next = "sp_sabotage_factoryFactoryFirstTurretPulled02",
        char = "wheatley",
        fires = {
            {
                entity = "@scanner_room_enter_trigger",
                input = "Enable",
                parameter = "",
                delay = 0,
                fireatstart = true
            },
            {
                entity = "@BringDefectiveTurret_trigger",
                input = "Enable",
                parameter = "",
                delay = 5,
                fireatstart = true
            },
            {
                entity = "@CrapTurretNag_trigger",
                input = "Enable",
                parameter = "",
                delay = 7,
                fireatstart = true
            },
            {
                entity = "wheatley_call_out_trigger",
                input = "Enable",
                parameter = "",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Template missing. Continuing from memory.
    SceneTable["sp_sabotage_factoryFactoryFirstTurretPulled02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory_line05.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactoryFirstTurretPulled03",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- Ohhh, it hasn't done it.
    SceneTable["sp_sabotage_factoryFactoryFirstTurretPulled03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone04.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactoryFirstTurretPulled04",
        char = "wheatley",
        fires = {
            {
                entity = "@WhereAreYouGoing_trigger",
                input = "Enable",
                parameter = "",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Right. Let's figure out how to stop this turret line...
    SceneTable["sp_sabotage_factoryFactoryFirstTurretPulled04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretconv23.vcd"),
        postdelay = 0.4,
        next = "sp_sabotage_factoryFactoryFirstTurretPulled05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Have you got any ideas?
    SceneTable["sp_sabotage_factoryFactoryFirstTurretPulled05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone06.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryFollowMe
    -- Follow me! You're gonna love this.
    SceneTable["sp_sabotage_factoryFactoryFollowMe01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2
    }

    -- FactoryScannerIntro
    -- See that scanner out there? It's deciding which turrets to keep and which to toss. And it's using that MASTER turret as a template! If we pull out the template turret, it'll shut down the whole production line.
    SceneTable["sp_sabotage_factoryFactoryScannerIntro01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory25.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@DoorHackIntro_relay",
                input = "Trigger",
                parameter = "",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryShoutout
    -- Sorry, what's going on over there? You know, I'm actually over here, still thinking really hard!
    SceneTable["sp_sabotage_factoryFactoryShoutout01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonewhere07.vcd"),
        postdelay = 0.7,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactorySuccessNoHint
    -- Oh, BRILLIANT! That's brilliant!
    SceneTable["sp_sabotage_factoryFactorySuccessNoHint01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturrettwoback11.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessNoHint02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 1.6
    }

    -- New template accepted.
    SceneTable["sp_sabotage_factoryFactorySuccessNoHint02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory_line04.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessNoHint03",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- If we're lucky, she won't find out all her turrets are crap until it's too late. {laughs} Classic.
    SceneTable["sp_sabotage_factoryFactorySuccessNoHint03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory16.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessNoHint04",
        char = "wheatley",
        fires = {
            {
                entity = "move_wheatley_to_hacking_spot_relay",
                input = "Trigger",
                parameter = "",
                delay = 3.6,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Okay! Keep your eye on the turret line, I'm gonna go and hack the door open.
    SceneTable["sp_sabotage_factoryFactorySuccessNoHint04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_dooropen03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactorySuccessWithHint
    -- New template accepted.
    SceneTable["sp_sabotage_factoryFactorySuccessWithHint01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory_line04.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessWithHint02",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- It worked!
    SceneTable["sp_sabotage_factoryFactorySuccessWithHint02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryworked02.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessWithHint03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- If we're lucky, she won't find out all her turrets are crap until it's too late. {laughs} Classic.
    SceneTable["sp_sabotage_factoryFactorySuccessWithHint03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory16.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactorySuccessWithHint04",
        char = "wheatley",
        fires = {
            {
                entity = "move_wheatley_to_hacking_spot_relay",
                input = "Trigger",
                parameter = "",
                delay = 3.6,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Okay! Keep your eye on the turret line, I'm gonna go and hack the door open.
    SceneTable["sp_sabotage_factoryFactorySuccessWithHint04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_dooropen03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryTahDah
    -- Tadah! Only the turret control center. Thank you very much.
    SceneTable["sp_sabotage_factoryFactoryTahDah01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory04.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactoryTahDah02",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Here, come and have a look out the window. It's good.
    SceneTable["sp_sabotage_factoryFactoryTahDah02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window01.vcd"),
        postdelay = 3,
        next = "sp_sabotage_factoryFactoryTahDah03",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Go on, just walk up to the window and take a look out.
    SceneTable["sp_sabotage_factoryFactoryTahDah03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window02.vcd"),
        postdelay = 0.3,
        next = "sp_sabotage_factoryFactoryTahDah04",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- It's interesting. You won't regret it. I promise.
    SceneTable["sp_sabotage_factoryFactoryTahDah04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window03.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factoryFactoryTahDah05",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Just glass. Transparent. Smooth. Not going to hurt you.
    SceneTable["sp_sabotage_factoryFactoryTahDah05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window05.vcd"),
        postdelay = 5,
        next = "sp_sabotage_factoryFactoryTahDah06",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Just... have a look through the old window.
    SceneTable["sp_sabotage_factoryFactoryTahDah06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window04.vcd"),
        postdelay = 7,
        next = "sp_sabotage_factoryFactoryTahDah07",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Go on. Walk up to the window. Take a look out.
    SceneTable["sp_sabotage_factoryFactoryTahDah07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_factory_window06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowEnd()",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "FactoryCheckAtWindowStart()",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagA
    -- Any ideas? Any ideas? No? No, me neither.
    SceneTable["sp_sabotage_factoryFactoryThinkNagA01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone12.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagB
    -- Are you still thinking, or... what's happening?
    SceneTable["sp_sabotage_factoryFactoryThinkNagB02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagC
    -- Tell you what, here's a plan. Let's just both... continue contemplating... in absolute silence...
    SceneTable["sp_sabotage_factoryFactoryThinkNagC08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagD
    -- Oh wait! I've got it I've got it I've got it! No, I haven't got it.
    SceneTable["sp_sabotage_factoryFactoryThinkNagD09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagE
    -- Oh! I've just had one idea, which is that I could pretend to her that I've captured you, and give you over and she'll kill you, but I could... go on living. What's your view on that?
    SceneTable["sp_sabotage_factoryFactoryThinkNagE10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone13.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagF
    -- There's no turret in it... Maybe the system stores a backup image?
    SceneTable["sp_sabotage_factoryFactoryThinkNagF11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagG
    -- Oh, hang on. What if we gave it something ELSE to scan?
    SceneTable["sp_sabotage_factoryFactoryThinkNagG12"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone17.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagH
    -- We could get one of the crap turrets, we could put it in the scanner and see what happens.
    SceneTable["sp_sabotage_factoryFactoryThinkNagH13"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone19.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryThinkNagI
    -- Yes! Go and catch one of the crap turrets, and bring it back.
    SceneTable["sp_sabotage_factoryFactoryThinkNagI14"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonedone20.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryWheatleyHey
    -- Ah! Brilliant. You made it through, well done.
    SceneTable["sp_sabotage_factoryFactoryWheatleyHey01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory23.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.5
    }

    -- FactoryWhereAreYouGoing
    -- Wait, where are you going? Where are you going?
    SceneTable["sp_sabotage_factoryFactoryWhereAreYouGoing01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonewhere01.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factoryFactoryWhereAreYouGoing02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Ohhhhh, have you got an idea?
    SceneTable["sp_sabotage_factoryFactoryWhereAreYouGoing02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonewhere03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- FactoryWhereAreYouGoingTwo
    -- Okay, well, alright. Just do your idea and then come straight back.
    SceneTable["sp_sabotage_factoryFactoryWhereAreYouGoingTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factoryturretonewhere05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- liveturret
    -- Live turret line is active. Enter room with extreme caution.
    SceneTable["sp_sabotage_factoryliveturret01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory16.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factoryliveturret02",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- Please avoid alerting active turrets or being shot by active turrets.
    SceneTable["sp_sabotage_factoryliveturret02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory17.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- nondefectivetesting
    -- Non-defective turret testing active.
    SceneTable["sp_sabotage_factorynondefectivetesting01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory20.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- redemption
    -- Turret redemption lines active.
    SceneTable["sp_sabotage_factoryredemption01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory13.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factoryredemption02",
        char = "announcerglados",
        noDingOff = true,
        noDingOn = true
    }

    -- Please do not engage with turrets heading towards redemption.
    SceneTable["sp_sabotage_factoryredemption02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory14.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcerglados",
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleA
    -- Get mad!
    SceneTable["sp_sabotage_factoryRedemptionBabbleA01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleB
    -- Don't make lemonade!
    SceneTable["sp_sabotage_factoryRedemptionBabbleB01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleC
    -- Prometheus was punished by the gods for giving the gift of knowledge to man. He was cast into the bowels of the earth and pecked by birds.
    SceneTable["sp_sabotage_factoryRedemptionBabbleC01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleD
    -- It won't be enough.
    SceneTable["sp_sabotage_factoryRedemptionBabbleD01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleE
    -- The answer is beneath us.
    SceneTable["sp_sabotage_factoryRedemptionBabbleE01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleF
    -- Her name is Carolyn.
    SceneTable["sp_sabotage_factoryRedemptionBabbleF01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleG
    -- Remember that!
    SceneTable["sp_sabotage_factoryRedemptionBabbleG01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionBabbleH
    -- That's all I can say.
    SceneTable["sp_sabotage_factoryRedemptionBabbleH01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionDie
    -- Ahh!
    SceneTable["sp_sabotage_factoryRedemptionDie01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        noDingOff = true,
        noDingOn = true
    }

    -- RedemptionPickedUp
    -- Thank you!
    SceneTable["sp_sabotage_factoryRedemptionPickedUp01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/different_turret01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_end()",
                delay = 0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_redemption_line_turret_babble_start()",
                delay = 0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- ridingliveturret
    -- This is a sterile environment; please refrain from riding on the turret line.
    SceneTable["sp_sabotage_factoryridingliveturret01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory18.vcd"),
        postdelay = 0.2,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- ridingredemption
    -- Turret redemption lines are not rides, please exit the turret redemption line.
    SceneTable["sp_sabotage_factoryridingredemption01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory15.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "announcerglados",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 6
    }

    -- sp_sabotage_diditwork
    -- Okay! Keep your eye on the turret line, I'm gonna go and hack the door open.
    SceneTable["sp_sabotage_factorysp_sabotage_diditwork01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_dooropen03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "move_wheatley_to_hacking_spot_relay",
                input = "Trigger",
                parameter = "",
                delay = 1.5,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1000
    -- Ah! Brilliant. You made it through, well done.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1001
    -- Follow me! You're gonna love this.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1002
    -- Hold on, partner. There's still some live turrets out there.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory19.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1003
    -- Drop down here!
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100301"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory20.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1004
    -- Wait there! I'll show you where to go from here.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory21.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1005
    -- Alright. Now she can't use her turrets no more. There's just ONE thing left to do: We've got to figure out a way to shut off her neurotoxin. Then she'll have NO WAY to fight back.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_100501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory22.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 7,
        queuepredelay = 1.5
    }

    -- sp_sabotage_factory_1101
    -- Almost there...
    SceneTable["sp_sabotage_factorysp_sabotage_factory_110101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_1104
    -- Tadah! Only the turret control center. Thank you very much.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_110401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2000
    -- See that scanner out there? It's deciding which turrets to keep and which to toss. And it's using that MASTER turret as a template! If we pull out the template turret, it'll shut down the whole production line.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_200001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory05.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_factorysp_sabotage_factory_200002",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We just need to get that turret out of there...
    SceneTable["sp_sabotage_factorysp_sabotage_factory_200002"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2015
    -- Right. Let me see if I can hack into the control computer.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_201501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2020
    -- There. You should be able to get in now.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_202001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2025
    -- We need to get the turret template out of there.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_202501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2030
    -- Try to get that turret out of there.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_203001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2035
    -- Template missing. Continuing from memory.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_203501"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory_line05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "wheatley_find_new_turret_relay",
                input = "Trigger",
                parameter = "",
                delay = 0.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2040
    -- Halfway there, partner. Now to swap in a crap one.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_204001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2045
    -- Halfway there, partner. Now to swap in a crap one.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_204501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2050
    -- We need to swap in a defective turret.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_205001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory12.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2055
    -- Try jumpin'!
    SceneTable["sp_sabotage_factorysp_sabotage_factory_205501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory13.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2060
    -- Ahhh, good catch!
    SceneTable["sp_sabotage_factorysp_sabotage_factory_206001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2070
    -- Go on! Swap it into the template spot.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_207001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory15.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2075
    -- New template accepted.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_207501"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_factory_line04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2095
    -- If we're lucky, she won't find out all her turrets are crap until it's too late. {laughs} Classic.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_209501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory16.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_factory_2105
    -- Alright, the door's open. Let's get out of here.
    SceneTable["sp_sabotage_factorysp_sabotage_factory_210501"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory18.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_hack_interrupt
    -- Ah! How long's the door been open?
    SceneTable["sp_sabotage_factorysp_sabotage_hack_interrupt01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoordone01.vcd"),
        postdelay = 0.2,
        next = "sp_sabotage_factorysp_sabotage_hack_interrupt02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Was there any sort of announcement before it opened? Like an alarm or a hacker alert? I mean, fair enough, I guess the important thing is it's open, but just mention in the future, cough or something, would you?
    SceneTable["sp_sabotage_factorysp_sabotage_hack_interrupt02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoordone02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "drop_down_here_trigger",
                input = "Enable",
                parameter = "",
                delay = 0.3
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_hack_outdoor
    -- This door's actually pretty complicated.
    SceneTable["sp_sabotage_factorysp_sabotage_hack_outdoor01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        skipifbusy = 1
    }

    -- sp_sabotage_reached_hacking_spot
    -- Okay, I'm about to start hacking. It's a little more complicated than it looked from your side. It should take about ten minutes. Keep one eye on the door.
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "factory_controlroom_exit_door_relay",
                input = "Trigger",
                parameter = "",
                delay = 10,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idleminsecs = 17.000,
        idlemaxsecs = 35.000,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 1,
        idlemaxplays = 1
    }

    -- You know when I mentioned ten minutes? A little bit optimistic!
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 2
    }

    -- Oh! Good news! {electic pop} Never mind.
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "bts4_computer_hack_spark()",
                delay = 1.384,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 3
    }

    -- What's happening on your side, anything?
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 4
    }

    -- Progress report: Still pretty tricky!
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 5
    }

    -- I'm still here, I'm still working, I haven't forgotten about you!
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 6
    }

    -- Progress report: Haven't really made any in-roads!
    SceneTable["sp_sabotage_factorysp_sabotage_reached_hacking_spot07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_factory_hackdoor06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_factorysp_sabotage_reached_hacking_spot",
        idleorderingroup = 7
    }

    -- sp_sabotage_redemption
    -- I'm different...
    SceneTable["sp_sabotage_factorysp_sabotage_redemption01"] = {
        vcd = CreateSceneEntity("scenes/npc/turret/turretstuckIntube09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "turret",
        noDingOff = true,
        noDingOn = true
    }

    -- Volcano
    -- Baking Soda Volcano. Well, it's not a potato battery, I'll give it that. Still not terrifically original, though. Not exactly primary research, even within the child sciences.
    SceneTable["sp_sabotage_factoryVolcano01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_science_fair02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairBusy()",
                delay = 0.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairNotBusy()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true,
        predelay = 0.2
    }

    -- VolcanoB
    -- I'm guessing this wasn't one of the scientist's children. I don't want to be snobby, but let's be honest: It's got manual laborer written all over it. I'm not saying they're not as good as the professionals. They're just a lot dumber.
    SceneTable["sp_sabotage_factoryVolcanoB02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_science_fair03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairBusy()",
                delay = 0.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "ScienceFairNotBusy()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true,
        predelay = 0.2
    }
end

-- sp_intro_01                             
-- sp_a2_bts5                              
if curMapName == "sp_a2_bts5" then
    -- ToxinCutAll
    -- That did it! Neurotoxin at zero percent! Yes!
    SceneTable["sp_a2_bts5ToxinCutAll01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hose_all01.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinCutAll02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on -
    SceneTable["sp_a2_bts5ToxinCutAll02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hose_all02.vcd"),
        postdelay = 4.0,
        next = "sp_a2_bts5ToxinCutAll04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Warning! Neurotoxin pressure has reached dangerously unlethal levels.
    SceneTable["sp_a2_bts5ToxinCutAll04"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/sp_sabotage_implosion01.vcd"),
        postdelay = 9.0,
        next = "sp_a2_bts5ToxinCutAll05",
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- HA! The tube's broken! We can ride it straight to her!
    SceneTable["sp_a2_bts5ToxinCutAll05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_tubebroken01.vcd"),
        postdelay = 0.5,
        next = "sp_a2_bts5ToxinCutAll06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I can't hold on! Come on!
    SceneTable["sp_a2_bts5ToxinCutAll06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin03.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinCutAll07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Come on! We have to go!
    SceneTable["sp_a2_bts5ToxinCutAll07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin01.vcd"),
        postdelay = 0.5,
        next = "sp_a2_bts5ToxinCutAll08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hurry!
    SceneTable["sp_a2_bts5ToxinCutAll08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin02.vcd"),
        postdelay = 0.7,
        next = "sp_a2_bts5ToxinCutAll09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- GET IN!
    SceneTable["sp_a2_bts5ToxinCutAll09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin04.vcd"),
        postdelay = 1.0,
        next = "sp_a2_bts5ToxinCutAll10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hurry!
    SceneTable["sp_a2_bts5ToxinCutAll10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin02.vcd"),
        postdelay = 0.7,
        next = "sp_a2_bts5ToxinCutAll11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- GET IN!
    SceneTable["sp_a2_bts5ToxinCutAll11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_getin06.vcd"),
        postdelay = 0.6,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ToxinCutFive
    -- It's still going down! Keep it up!
    SceneTable["sp_a2_bts5ToxinCutFive01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hose_any01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queuetimeout = 0.2
    }

    -- ToxinCutFour
    -- Hold on, something's wrong! Neurotoxin level's up to 50%! Down. I mean down to fifty. Good news! Carry on!
    SceneTable["sp_a2_bts5ToxinCutFour01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hose_half02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2.3
    }

    -- ToxinCutOffFrontOfRoom
    -- What are you doing in there?
    SceneTable["sp_a2_bts5ToxinCutOffFrontOfRoom01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_laser_cut01.vcd"),
        postdelay = 1.0,
        next = "sp_a2_bts5ToxinCutOffFrontOfRoom02",
        char = "wheatley",
        fires = {
            {
                entity = "@sphere_lookat_player_relay",
                input = "trigger",
                parameter = "",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true,
        predelay = 0.8
    }

    -- What's going on?
    SceneTable["sp_a2_bts5ToxinCutOffFrontOfRoom02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_laser_cut02.vcd"),
        postdelay = 2.0,
        next = "sp_a2_bts5ToxinCutOffFrontOfRoom03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Are you alright?
    SceneTable["sp_a2_bts5ToxinCutOffFrontOfRoom03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_laser_cut03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ToxinCutOne
    -- Do you smell neurotoxin?
    SceneTable["sp_a2_bts5ToxinCutOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_first_hose01.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinCutOne02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.6
    }

    -- Hold on! The neurotoxin levels are going down.
    SceneTable["sp_a2_bts5ToxinCutOne02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_first_hose02.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinCutOne03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- So whatever you're doing, keep doing it!
    SceneTable["sp_a2_bts5ToxinCutOne03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_first_hose03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ToxinDoorIsNowOpen
    -- WHOAH! WE DON'T KNOW WHAT THAT BUTTON - oh, the door's open! Well done. Let's see what's inside.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_dooropen_press01.vcd"),
        postdelay = 1.5,
        next = "sp_a2_bts5ToxinDoorIsNowOpen02",
        char = "wheatley",
        fires = {
            {
                entity = "open_door_rl",
                input = "trigger",
                parameter = "",
                delay = 0.0,
                fireatstart = true
            },
            {
                entity = "move_into_room_rl",
                input = "trigger",
                parameter = "",
                delay = 3.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Good news! I can use this equipment to shut down the neurotoxin system. It is, however, password protected. AH! Alarm bells! No. Don't worry. Not a problem for me.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack01.vcd"),
        postdelay = 0.3,
        next = "sp_a2_bts5ToxinDoorIsNowOpen03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You may as well have a little rest while I work on it.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack02.vcd"),
        postdelay = 1.0,
        next = "sp_a2_bts5ToxinDoorIsNowOpen04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Ok... Here we go...
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack03.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen05",
        char = "wheatley",
        fires = {
            {
                entity = "@sphere_lookat_computer_relay",
                input = "trigger",
                parameter = "",
                delay = 0.1,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- The hardest part of any hack is the figuring-out-how-to-start phase. So, let the games begin.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack04.vcd"),
        postdelay = 0.3,
        next = "sp_a2_bts5ToxinDoorIsNowOpen06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Allright, what have we got.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack05.vcd"),
        postdelay = 0.5,
        next = "sp_a2_bts5ToxinDoorIsNowOpen07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- A computer. Not a surprise. Expected. Check that off the list. Tick.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack06.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- There is a box part. Probably got some electronics in there.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack07.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And a monitor. Yes. That'll be important, I imagine. I'll keep my eye on that.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack08.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And there's a flat bit. Not sure what that is. But: noted. If anyone says to me is there a flat bit? Yes, there it is.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack09.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Spinning thing. Hmmm. Not sure.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack10.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen12",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- The floor. What's the floor up to? Do you know what? It's holding everything up. The floor is important, holding everything up.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen12"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack11.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen13",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Pens. Might need those. Don't see any though. So...
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen13"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack12.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen14",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- If we start making a list of things that aren't here, we could be here all night.  You know, pens for instance. Let's stick with things we can see. Not things that aren't here.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen14"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack13.vcd"),
        postdelay = 2.0,
        next = "sp_a2_bts5ToxinDoorIsNowOpen15",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Allright. Preparing to interface with the neurotoxin central control circuit. 'Ello, guv! Neurotoxin inspectah! Need to shut this place down for a moment! Here's my credentials. Shut yourself down. I am totally legit.  From the board of international ne
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen15"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack14.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen16",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Nothing. He's good. Need to break out the expert level hacking maneuvers now. You asked for it Mate.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen16"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack15.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen17",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- "Caw! Caw!" Oh, look! There's a bird out here! A beautiful bird. Gorgeous plumage. Majestic. Won't stay here long. Once in a lifetime
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen17"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack16.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen18",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Be a shame to miss it. Just for neurotoxin. Neurotoxin'll still be there tomorrow. Unlike the bird, which already has one talon off the branch.
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen18"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack17.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinDoorIsNowOpen19",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, its fluttering its wings. Tell you what, mate. I'll come in there for a minute and cover for you so you can see this bird! Ohhh, it's lovely. Seriously, my pleasure sounds are going to frighten the bird away any second. Ohhh, this bird! Ohhh, this
    SceneTable["sp_a2_bts5ToxinDoorIsNowOpen19"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_hack18.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ToxinIntoTube
    -- Gah!
    SceneTable["sp_a2_bts5ToxinIntoTube01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_wheatley_ows12.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ToxinTheDoorIsLocked
    -- I'm afraid the door's locked. No way to hack it as far as I can see. The mechanism must be on the -oh, now that is a big laser!
    SceneTable["sp_a2_bts5ToxinTheDoorIsLocked01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_lockeddoor01.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinTheDoorIsLocked02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Best to ignore it, though. Just leave it be. We don't know where those panels it's cutting are headed. Could be somewhere important.
    SceneTable["sp_a2_bts5ToxinTheDoorIsLocked02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_lockeddoor02.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinTheDoorIsLocked03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Though it does give me an idea: WHAT if we stand here and let the gentle hum of the laser transport us to a state of absolute relaxation. Might help us think of a way to open the door.
    SceneTable["sp_a2_bts5ToxinTheDoorIsLocked03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_lockeddoor03.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinTheDoorIsLocked04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Not much of a plan, if I'm honest. But I'm afraid it's all we have at his point. Barring a sudden fusillade of speech from your direction. Improbable. At best.
    SceneTable["sp_a2_bts5ToxinTheDoorIsLocked04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_lockeddoor04.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5ToxinTheDoorIsLocked05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Alright, so, silent contemplation. It is. Mysterious button... Sorry. Sorry. Silence. Don not speak. In the silence. Let the silence descend. Here it comes. One hundred percent silence. From now.  By the way, if you come up with any ideas, do flag them
    SceneTable["sp_a2_bts5ToxinTheDoorIsLocked05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_lockeddoor05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TurretDestructionOurHandiwork
    -- Our handiwork. Shouldn't laugh. They do feel pain. Of a sort. All simulated. Still, it's real enough to them I suppose.
    SceneTable["sp_a2_bts5TurretDestructionOurHandiwork01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_grinder02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_move_to_laser_rl",
                input = "trigger",
                parameter = "",
                delay = 7.5,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- WheatleyGreetsYou
    -- Ha! I knew we were going the right way.
    SceneTable["sp_a2_bts5WheatleyGreetsYou01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_intro01.vcd"),
        postdelay = 0.3,
        next = "sp_a2_bts5WheatleyGreetsYou02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- This is the neurotoxin generator. Bit bigger than I expected.  Not going to be able to just, you know, push it over. Have to apply some cleverness.
    SceneTable["sp_a2_bts5WheatleyGreetsYou02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_intro02.vcd"),
        postdelay = 0.1,
        next = "sp_a2_bts5WheatleyGreetsYou03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- There's some sort of control room up top. Let's go investigate.
    SceneTable["sp_a2_bts5WheatleyGreetsYou03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts5_intro03.vcd"),
        postdelay = 0.3,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_intro_finished_rl",
                input = "trigger",
                parameter = "",
                delay = 2.8,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_sabotage_panel_sneak                 
if curMapName == "sp_sabotage_panel_sneak" then
    -- sp_sabotage_panel_sneak_1000
    -- Alright, now. She can't use her turrets. So let's go and take care of that neurotoxin generator as well. If we can find a feeder tube, it should lead us right to it.
    SceneTable["sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100001"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_panel_sneak01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- sp_sabotage_panel_sneak_1001
    -- Drop down here onto this track!
    SceneTable["sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_panel_sneak02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_panel_sneak_1002
    -- Hey, I can see it! The feeder tube's just in the next room!
    SceneTable["sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100201"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_panel_sneak03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- sp_sabotage_panel_sneak_1003
    -- Follow the feeder tube to the generator room! I'll meet you there.
    SceneTable["sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100301"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_panel_sneak04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_bts6                                        
if curMapName == "sp_a2_bts6" then
    -- StartTubeRide
    -- This should take us right to her. I can't believe I'm finally doing this!
    SceneTable["sp_sabotage_tube_rideStartTubeRide01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride03.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_tube_rideStartTubeRide02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 2.5
    }

    -- Woooo! See, I KNEW this would be fun. They told me it wasn't fun at all, and I BELIEVED 'em! Ah! I'm loving this! Whale of a time...
    SceneTable["sp_sabotage_tube_rideStartTubeRide02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride02.vcd"),
        postdelay = 4,
        next = "sp_sabotage_tube_rideStartTubeRide03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- This place is huge.
    SceneTable["sp_sabotage_tube_rideStartTubeRide03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts6_tuberide01.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_tube_rideStartTubeRide04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And we're only seeing the top layer. It goes down for miles.
    SceneTable["sp_sabotage_tube_rideStartTubeRide04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts6_tuberide02.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_tube_rideStartTubeRide05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- All sealed off years ago, of course.
    SceneTable["sp_sabotage_tube_rideStartTubeRide05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts6_tuberide05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TubeRideUhOh
    -- We should be getting close. Ohh, I can't wait to see the look on her face. No neurotoxin, no turrets--she'll never know what hit her!
    SceneTable["sp_sabotage_tube_rideTubeRideUhOh01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride05.vcd"),
        postdelay = 0.1,
        next = "sp_sabotage_tube_rideTubeRideUhOh02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.6
    }

    -- Hold on now. I might not have thought this next part COMPLETELY through.
    SceneTable["sp_sabotage_tube_rideTubeRideUhOh02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride06.vcd"),
        postdelay = 0.0,
        next = "sp_sabotage_tube_rideTubeRideUhOh03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Aggh! I'm going the wrong way!
    SceneTable["sp_sabotage_tube_rideTubeRideUhOh03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride01.vcd"),
        postdelay = 0.5,
        next = "sp_sabotage_tube_rideTubeRideUhOh04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Get to HER! I'll find you!
    SceneTable["sp_sabotage_tube_rideTubeRideUhOh04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_tube_ride07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_pit_flings                        
if curMapName == "sp_a2_pit_flings" then
    -- End
    -- Hmm. This emancipation grill is broken.
    SceneTable["sp_a2_pit_flingsEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_pit_flings01.vcd"),
        postdelay = 0.3,
        next = "sp_a2_pit_flingsEnd02",
        char = "glados"
    }

    -- Don't take anything with you.
    SceneTable["sp_a2_pit_flingsEnd02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_pit_flings02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados"
    }

    -- Start
    -- Did you know that people with guilty consciences are more easily startled by loud noi-{foghorn}
    SceneTable["sp_a2_pit_flingsStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_wall_jumps01.vcd"),
        postdelay = 0.0,
        next = "sp_a2_pit_flingsStart02",
        char = "glados",
        predelay = 1.0
    }

    -- I'm sorry, I don't know why that went off. Anyway, just an interesting science fact.
    SceneTable["sp_a2_pit_flingsStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_paint_jump_wall_jumps02.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "glados"
    }
end

-- sp_a2_ricochet                          
if curMapName == "sp_a2_ricochet" then
    -- End
    -- Well, you passed the test. I didn't see the deer today. I did see some humans. But with you here I've got more test subjects than I'll ever need.
    SceneTable["sp_a2_ricochetEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc27.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        predelay = 0.5
    }

    -- FutureStarter
    -- If you think trapping yourself is going to make me stop testing, you're sorely mistaken. Here's another cube.
    SceneTable["sp_a2_ricochetFutureStarter01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_future_starter01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "reflector_cube_button",
                input = "press",
                parameter = "",
                delay = 6.0,
                fireatstart = true
            }
        }
    }

    -- Start
    -- Enjoy this next test. I'm going to go to the surface. It's a beautiful day out. Yesterday I saw a deer. If you solve this next test, maybe I'll let you ride an elevator all the way up to the break room, and I'll tell you about the time I saw a deer
    SceneTable["sp_a2_ricochetStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_ricochet01.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "glados",
        predelay = 1.0
    }
end

-- sp_a2_pull_the_rug                      
if curMapName == "sp_a2_pull_the_rug" then
    -- End
    -- I'll bet you think I forgot about your surprise. I didn't. In fact, we're headed to your surprise right now. After all these years. I'm getting choked up just thinking about it.
    SceneTable["sp_a2_pull_the_rugEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc33.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- It says this next test was designed by one of Aperture's Nobel prize winners! It doesn't say what the prize was for. Well, I know it wasn't for Being Immune To Neurotoxin.
    SceneTable["sp_a2_pull_the_rugStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/testchambermisc39.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        predelay = 1.8
    }
end

-- sp_a1_intro7                            
if curMapName == "sp_a1_intro7" then
    -- BamSecretPanel
    -- BAM! Secret panel! That I opened. While your back was turned.
    SceneTable["sp_a1_intro7BamSecretPanel01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/secretpanelopens07.vcd"),
        postdelay = 0.5,
        next = "sp_a1_intro7BamSecretPanel02",
        char = "wheatley",
        fires = {
            {
                entity = "@plug_eject_rl",
                input = "Trigger",
                parameter = "",
                delay = 2,
                fireatstart = true
            },
            {
                entity = "@plug_close_rl",
                input = "Trigger",
                parameter = "",
                delay = 4,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Pick me up. Let's get out of here.
    SceneTable["sp_a1_intro7BamSecretPanel02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/callingoutinitial14.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Pick--would you pick me up?
    SceneTable["sp_a1_intro7BamSecretPanel03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags05.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- {laugh} Would you pick me up?
    SceneTable["sp_a1_intro7BamSecretPanel04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags07.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hey! Pick me up!
    SceneTable["sp_a1_intro7BamSecretPanel05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags01.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Pick me up, don't forget to pick me up!
    SceneTable["sp_a1_intro7BamSecretPanel06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags10.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Might want to just pick me up.
    SceneTable["sp_a1_intro7BamSecretPanel07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags11.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh! Oh! Don't leave me behind! Do pick me up, if you would...
    SceneTable["sp_a1_intro7BamSecretPanel08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags13.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Just, ah... pick me up. Take me with you.
    SceneTable["sp_a1_intro7BamSecretPanel09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags15.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Ohhh. Remember when you picked me up? Five seconds ago! Ohhh, that was amazing! Do it again, pick me up again!
    SceneTable["sp_a1_intro7BamSecretPanel10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags16.vcd"),
        postdelay = {0.000, 7.000},
        next = "sp_a1_intro7BamSecretPanel11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Let's do it again! Pick me up again!
    SceneTable["sp_a1_intro7BamSecretPanel11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_pickupnags17.vcd"),
        postdelay = {0.000, 7.000},
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- ComeThroughNag
    -- Come on through.
    SceneTable["sp_a1_intro7ComeThroughNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro13.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        idle = true,
        idlerepeat = true,
        idlerandomonrepeat = true,
        idleminsecs = 4.000,
        idlemaxsecs = 6.000,
        idlegroup = "sp_a1_intro7comethroughnag",
        idleorderingroup = 1
    }

    -- Come on through to the other side.
    SceneTable["sp_a1_intro7ComeThroughNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7comethroughnag",
        idleorderingroup = 2
    }

    -- Come on through.
    SceneTable["sp_a1_intro7ComeThroughNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro15.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7comethroughnag",
        idleorderingroup = 3
    }

    -- GloriousFreedom
    -- Look at this! No rail to tell us where to go! OH, this is brilliant. We can go where ever we want! Hold on, though, where are we going? Seriously. Hang on, let me just get my bearings. Hm. Just follow the rail, actually.
    SceneTable["sp_a1_intro7GloriousFreedom01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gloriousfreedom03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- HeyUpHere
    -- Hey! Oi oi! I'm up here!
    SceneTable["sp_a1_intro7HeyUpHere01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_intro02.vcd"),
        postdelay = 0.1,
        next = nil,
        queuecharacter = "glados",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- HoboTurretPass
    -- Oh no...
    SceneTable["sp_a1_intro7HoboTurretPass01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_hoboturret01.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7HoboTurretPass02",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true,
        predelay = 0.3
    }

    -- Yes, hello! We're not stopping!
    SceneTable["sp_a1_intro7HoboTurretPass02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_hoboturret08.vcd"),
        postdelay = 0.2,
        next = "sp_a1_intro7HoboTurretPass03",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Don't make eye contact whatever you do...
    SceneTable["sp_a1_intro7HoboTurretPass03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_hoboturret07.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7HoboTurretPass04",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- No thanks! We're good! Appreciate it!
    SceneTable["sp_a1_intro7HoboTurretPass04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_hoboturret05.vcd"),
        postdelay = 0.1,
        next = "sp_a1_intro7HoboTurretPass05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Keep moving, keep moving...
    SceneTable["sp_a1_intro7HoboTurretPass05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_intro7_hoboturret06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Impact
    -- OW.
    SceneTable["sp_a1_intro7Impact01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherethud03.vcd"),
        postdelay = 0.4,
        next = "sp_a1_intro7Impact02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- OW...
    SceneTable["sp_a1_intro7Impact02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherethud04.vcd"),
        postdelay = 1.2,
        next = "sp_a1_intro7Impact03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I. Am. Not. Dead! I'm not dead! {laughter}
    SceneTable["sp_a1_intro7Impact03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherethud06.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7Impact04",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_NotDeadStart()",
                delay = 0.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_NotDeadEnd()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- I can't move, though. That's the problem now.
    SceneTable["sp_a1_intro7Impact04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherethud08.vcd"),
        postdelay = 0.3,
        next = "sp_a1_intro7Impact05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Are you still there? Can you pick me up, do you think? If you are there?
    SceneTable["sp_a1_intro7Impact05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@sphere",
                input = "EnablePickup",
                parameter = "",
                delay = 2.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PickMeUpNag()",
                delay = 6.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- ManagementRail
    -- Okay, listen, let me lay something on you here. It's pretty heavy. They told me NEVER NEVER EVER to disengage myself from my Management Rail. Or I would DIE. But we're out of options here.
    SceneTable["sp_a1_intro7ManagementRail01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildropintro01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "catch_trigger_fake",
                input = "Enable",
                parameter = "",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- NoWatching
    -- Ummmm. Yeah, I can't do it if you're watching.
    SceneTable["sp_a1_intro7NoWatching01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence10.vcd"),
        postdelay = 0.2,
        next = "sp_a1_intro7NoWatching02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.7
    }

    -- Seriously, I'm not joking. Could you just turn around for a second?
    SceneTable["sp_a1_intro7NoWatching02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_dont_watch_aisc",
                input = "Enable",
                parameter = "",
                delay = 0.2
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_NoWatchingNag()",
                delay = 7
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- NoWatchingNag
    -- I can't... I can't do it if you're watching. {nervous laugh}
    SceneTable["sp_a1_intro7NoWatchingNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerepeat = true,
        idlerandomonrepeat = true,
        idleminsecs = 6.000,
        idlemaxsecs = 14.000,
        idlegroup = "sp_a1_intro7nowatchingnag",
        idleorderingroup = 1
    }

    -- I can't do it if you're watching. If you.... just turn around?
    SceneTable["sp_a1_intro7NoWatchingNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7nowatchingnag",
        idleorderingroup = 2
    }

    -- What's that behind you? It's only a robot on a bloody stick! A different one!
    SceneTable["sp_a1_intro7NoWatchingNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence16.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7nowatchingnag",
        idleorderingroup = 3,
        idlemaxplays = 1
    }

    -- Alright. {nervous laugh} Can't do it if you're leering at me. Creepy.
    SceneTable["sp_a1_intro7NoWatchingNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence13.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7nowatchingnag",
        idleorderingroup = 4,
        idlemaxplays = 1
    }

    -- Okay. Listen. I can't do it with you watching. I know it seems pathetic, given what we've been through. But just turn around. Please?
    SceneTable["sp_a1_intro7NoWatchingNag05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence20.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7nowatchingnag",
        idleorderingroup = 5,
        idlemaxplays = 1
    }

    -- OnThree
    -- On three. Ready? One... Two...
    SceneTable["sp_a1_intro7OnThree01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherecatch02.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7OnThree02",
        char = "wheatley",
        fires = {
            {
                entity = "spherebot_train_1_chassis_1",
                input = "StartBackward",
                parameter = "",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- THREE! That's high. It's TOO high, isn't it, really, that--
    SceneTable["sp_a1_intro7OnThree02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherecatch05.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7OnThree03",
        char = "wheatley",
        fires = {
            {
                entity = "spherebot_train_1_chassis_1",
                input = "Stop",
                parameter = "",
                delay = 1.3,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Alright, going on three just gives you too much time to think about it. Let's, uh, go on one this time. Okay, ready?
    SceneTable["sp_a1_intro7OnThree03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherecatch07.vcd"),
        postdelay = 0.0,
        next = "sp_a1_intro7OnThree04",
        char = "wheatley",
        fires = {
            {
                entity = "spherebot_train_1_chassis_1",
                input = "StartForward",
                parameter = "",
                delay = 2.0,
                fireatstart = true
            },
            {
                entity = "look_floor_rl",
                input = "Trigger",
                parameter = "",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- ONE Catchmecatchmecatchmecatchmecatchme--OHHH!
    SceneTable["sp_a1_intro7OnThree04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefall04.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@sphere",
                input = "ClearParent",
                parameter = "",
                delay = 0.1,
                fireatstart = true
            },
            {
                entity = "sphere_impact_trigger",
                input = "Enable",
                parameter = "",
                delay = 0.00,
                fireatstart = true
            },
            {
                entity = "spherebot_train_1_chassis_1",
                input = "SetSpeedReal",
                parameter = "20",
                delay = 0.00,
                fireatstart = true
            },
            {
                entity = "sphere_detach_spark",
                input = "SparkOnce",
                parameter = "",
                delay = 0.1,
                fireatstart = true
            },
            {
                entity = "sphere_teleport",
                input = "Teleport",
                parameter = "",
                delay = 0.09,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- PickedUp
    -- Oh! Brilliant, thank you, great.
    SceneTable["sp_a1_intro7PickedUp01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppickup02.vcd"),
        postdelay = 0.2,
        next = "sp_a1_intro7PickedUp02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Plug me into that stick on the wall over there. Yeah? And I'll show you something. You'll be impressed by this.
    SceneTable["sp_a1_intro7PickedUp02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@plug_open_rl",
                input = "Trigger",
                parameter = "",
                delay = 2.5,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PlugMeInNag()",
                delay = 4.5
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- PickedUpDuringNotDead
    -- Plug me into that stick on the wall over there. Yeah? And I'll show you something. You'll be impressed by this.
    SceneTable["sp_a1_intro7PickedUpDuringNotDead01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@plug_open_rl",
                input = "Trigger",
                parameter = "",
                delay = 2.5,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PlugMeInNag()",
                delay = 4.5
            }
        },
        noDingOff = true,
        noDingOn = true,
        predelay = 0.3
    }

    -- PickedUpFast
    -- I. Am. Not. Dead! I'm not dead! {laughter}
    SceneTable["sp_a1_intro7PickedUpFast01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherethud06.vcd"),
        postdelay = 0.3,
        next = "sp_a1_intro7PickedUpFast02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Plug me into that stick on the wall over there. Yeah? And I'll show you something. You'll be impressed by this.
    SceneTable["sp_a1_intro7PickedUpFast02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@plug_open_rl",
                input = "Trigger",
                parameter = "",
                delay = 2.5,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PlugMeInNag()",
                delay = 4.5
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- PickedUpTwo
    -- And off we go.
    SceneTable["sp_a1_intro7PickedUpTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_fire_lift03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- PickMeUpNag
    -- Hello? Can you--can you pick me up, please?
    SceneTable["sp_a1_intro7PickMeUpNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idleminsecs = 3.000,
        idlemaxsecs = 10.000,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 1
    }

    -- Sorry, are you still there? Could you--could you pick me up?
    SceneTable["sp_a1_intro7PickMeUpNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 2
    }

    -- If you ARE there, would you mind... giving me a little bit of help? {nervous laugh} Just picking me up.
    SceneTable["sp_a1_intro7PickMeUpNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 3
    }

    -- Look down. Where am I? Where am I.
    SceneTable["sp_a1_intro7PickMeUpNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall09.vcd"),
        postdelay = 0.1,
        next = "sp_a1_intro7PickMeUpNag0401",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 4,
        idleindex = 1
    }

    -- NAG CHAIN: On the floor. Needing your help. The whole time. All the time. Needing your help.
    SceneTable["sp_a1_intro7PickMeUpNag0401"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall16.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 5,
        idleunder = 1
    }

    -- Still here on the floor. Waiting to be picked up. Um.
    SceneTable["sp_a1_intro7PickMeUpNag06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall17.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 6
    }

    -- Look down. Who's that, down there, talking? It's me! Down on the floor. Needing you to pick me up.
    SceneTable["sp_a1_intro7PickMeUpNag07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall19.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 7
    }

    -- I spy with my little eye, something that starts with 'f'.
    SceneTable["sp_a1_intro7PickMeUpNag08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall10.vcd"),
        postdelay = 0.4,
        next = "sp_a1_intro7PickMeUpNag0801",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 8,
        idleindex = 2
    }

    -- NAG CHAIN: Do you give up? It was the floor. Lying down on the floor. Is where I am. Needing you to pick me up.
    SceneTable["sp_a1_intro7PickMeUpNag0801"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall12.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 9,
        idleunder = 2
    }

    -- Don't want to hassle you. Sure you're busy. But--still here on the floor. Waiting to be picked up.
    SceneTable["sp_a1_intro7PickMeUpNag10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall15.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 10
    }

    -- Now I spy something that starts with an 'a'.
    SceneTable["sp_a1_intro7PickMeUpNag11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall13.vcd"),
        postdelay = 0.4,
        next = "sp_a1_intro7PickMeUpNag1101",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 11,
        idleindex = 3
    }

    -- NAG CHAIN: Give up? Also the floor. Was the answer that time. Same as before. Still on the floor.
    SceneTable["sp_a1_intro7PickMeUpNag1101"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 12,
        idleunder = 3
    }

    -- What are you doing, are you just having a little five minutes to yourself? Fair enough. You've had a rough time. You've been asleep for  who knows how long.
    SceneTable["sp_a1_intro7PickMeUpNag13"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/raildroppostfall20.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7pickmeupnag",
        idleorderingroup = 13
    }

    -- PlugMeInNag
    -- Go on. Just jam me in over there.
    SceneTable["sp_a1_intro7PlugMeInNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerepeat = true,
        idlerandomonrepeat = true,
        idleminsecs = 4.000,
        idlemaxsecs = 10.000,
        idlegroup = "sp_a1_intro7plugmeinnag",
        idleorderingroup = 1
    }

    -- Right on that stick over there. Just put me right on it.
    SceneTable["sp_a1_intro7PlugMeInNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7plugmeinnag",
        idleorderingroup = 2
    }

    -- It is tricky. It is tricky. But just... plug me in, please.
    SceneTable["sp_a1_intro7PlugMeInNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7plugmeinnag",
        idleorderingroup = 3
    }

    -- Plug me into that stick on the wall over there. I'll show you something.
    SceneTable["sp_a1_intro7PlugMeInNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7plugmeinnag",
        idleorderingroup = 4
    }

    -- It DOES sound rude. I'm not going to lie to you. It DOES sound rude. It's not. Put me right on it. Stick me in.
    SceneTable["sp_a1_intro7PlugMeInNag05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherefirstdoorwaysequence08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7plugmeinnag",
        idleorderingroup = 5,
        idlemaxplays = 1
    }

    -- PopPortal
    -- Pop a portal on that wall behind me there, and I'll meet you on the other side of the room.
    SceneTable["sp_a1_intro7PopPortal01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PopPortalNag()",
                delay = 4.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- PopPortalNag
    -- Just pop a portal right behind me there, and come on through to the other side.
    SceneTable["sp_a1_intro7PopPortalNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerepeat = true,
        idlerandomonrepeat = true,
        idleminsecs = 4.000,
        idlemaxsecs = 6.000,
        idlegroup = "sp_a1_intro7popportalnag",
        idleorderingroup = 1
    }

    -- Pop a little portal, just there, alright? Behind me. And come on through.
    SceneTable["sp_a1_intro7PopPortalNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7popportalnag",
        idleorderingroup = 2
    }

    -- Right behind me.
    SceneTable["sp_a1_intro7PopPortalNag03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7popportalnag",
        idleorderingroup = 3
    }

    -- Alright, let me explain again. Pop a portal. Behind me. Alright? And come on through.
    SceneTable["sp_a1_intro7PopPortalNag04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7popportalnag",
        idleorderingroup = 4
    }

    -- Pop a portal. Behind me, on the wall. Come on through.
    SceneTable["sp_a1_intro7PopPortalNag05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereintro11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_a1_intro7popportalnag",
        idleorderingroup = 5
    }

    -- Start
    -- To ensure that sufficient power remains for core testing protocols, all safety devices have been disabled. The Enrichment Center respects your right to have questions or concerns about this policy.
    SceneTable["sp_a1_intro7Start01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        noDingOff = true,
        noDingOn = true
    }

    -- TurnAroundNow
    -- Alright, you can turn around now!
    SceneTable["sp_a1_intro7TurnAroundNow01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/turnaroundnow01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_watch_aisc",
                input = "Enable",
                parameter = "",
                delay = 0.1
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- YouFoundIt
    -- Oh, brilliant. You DID find a portal gun! You know what? It just goes to show: people with brain damage are the real heroes in the end aren't they? At the end of the day. Brave.
    SceneTable["sp_a1_intro7YouFoundIt01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/DEMOSPHEREINTRO04.vcd"),
        postdelay = 0.4,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro7_PopPortal()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }
end

-- sp_a1_wakeup                            
if curMapName == "sp_a1_wakeup" then
    -- ChamberDoorOpen
    -- Okay, I'm gonna lay my cards on the table: I don't wanna do it. I don't want to go in there. Don't... Don't go in there - She's off. She's off! Panic over! She's off. On we go.
    SceneTable["sp_a1_wakeupChamberDoorOpen01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_gantry01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.1,
        queue = 1
    }

    -- ComeThroughHere
    -- Ohh. You're gonna laugh at this. You know how I said there was absolutely no way to get here without going through her lair and her potentially killing us?
    SceneTable["sp_a1_wakeupComeThroughHere01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosunderchamber01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- DoNotLookDown
    -- AH! I just looked down. I do not recommend it.
    SceneTable["sp_a1_wakeupDoNotLookDown01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_catwalk01.vcd"),
        postdelay = 0.2,
        next = "sp_a1_wakeupDoNotLookDown02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- AH! I've just done it again.
    SceneTable["sp_a1_wakeupDoNotLookDown02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_catwalk02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_Do_Not_Look_Down_Over()",
                delay = 0.1
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- DoNotTouch
    -- Look for a switch that says ESCAPE POD. Alright? Don't touch ANYTHING else.
    SceneTable["sp_a1_wakeupDoNotTouch01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereswitchroom09.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupDoNotTouch02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 3
    }

    -- Not interested in anything else. Don't TOUCH anything else. Don't even LOOK at anything else, just--well, obviously you've got to look at everything else to find ESCAPE POD, but as soon as you've looked at something and it doesn't say ESCAPE POD,
    SceneTable["sp_a1_wakeupDoNotTouch02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereswitchroom05.vcd"),
        postdelay = 0.7,
        next = "sp_a1_wakeupDoNotTouch03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Can you see it anywhere? I can't see it anywhere. Uh. Tell you what, plug me in and I'll switch the old lights on.
    SceneTable["sp_a1_wakeupDoNotTouch03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereswitchroom06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "basement_breakers_socket_relay",
                input = "Trigger",
                parameter = "",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- DownTheStairs
    -- Okay, down these stairs.
    SceneTable["sp_a1_wakeupDownTheStairs01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherestairs07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Falling
    -- {yelling}
    SceneTable["sp_a1_wakeupFalling01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_panic01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JumpNags
    -- Jump! Actually, looking at it, that is quite a distance, isn't it?
    SceneTable["sp_a1_wakeupJumpNags01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump01.vcd"),
        postdelay = 1.0,
        next = "sp_a1_wakeupJumpNags02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You know what? Go ahead and jump. You've got braces on your legs. No braces on your arms, though. Gonna have to rely on the old human strength to keep a grip on the device and, by extension, me. So do. Do make sure to maintain a grip.
    SceneTable["sp_a1_wakeupJumpNags02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump11.vcd"),
        postdelay = 0.3,
        next = "sp_a1_wakeupJumpNags03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Also, a note: No braces on your spine, either. So don't land on that.  Or your head, no braces there. That could split like a melon from this height. {nervous chuckle} Do definitely focus on landing with your legs.
    SceneTable["sp_a1_wakeupJumpNags03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump12.vcd"),
        postdelay = 1,
        next = "sp_a1_wakeupJumpNags04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Quick question: Have you been working out? Because there's no evidence of it. I'm not a plastic cup. We will be landing with some force. So use some grip.
    SceneTable["sp_a1_wakeupJumpNags04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump03.vcd"),
        postdelay = 1,
        next = "sp_a1_wakeupJumpNags05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- So go ahead and jump. What's the worst that could happen? Oh. Oh wait, I just now thought of the worst thing. Oh! I just thought of something even worse.
    SceneTable["sp_a1_wakeupJumpNags05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump13.vcd"),
        postdelay = 1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Landed
    -- Still held! Still bein' held. That's great. You've applied the grip. We're all fine. That's tremendous.
    SceneTable["sp_a1_wakeupLanded01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_jump05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- LetsGoIn
    -- Let's go in!
    SceneTable["sp_a1_wakeupLetsGoIn01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_into_breakerroom01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- LightsOn
    -- "Let there be light." That's, uh... God. I was quoting God.
    SceneTable["sp_a1_wakeupLightsOn01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereswitchroom08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- MainBreakerRoom
    -- This is the main breaker room.
    SceneTable["sp_a1_wakeupMainBreakerRoom01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demosphereswitchroom04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_Lets_Go_In()",
                delay = 1.0
            }
        },
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2
    }

    -- SecondThoughtsA
    -- If you want to just call it quits, we could just sit here. Forever. That's an option. Option A: Sit here. Do nothing. Option B: Go through there, and if she's alive, she'll almost certainly kill us.
    SceneTable["sp_a1_wakeupSecondThoughtsA01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry15.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_gantry_exposition_end()",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- SecondThoughtsB
    -- So. If you've got any reservations whatsoever about this plan, now would be the time to voice them.
    SceneTable["sp_a1_wakeupSecondThoughtsB01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_gantry_exposition_end()",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- SecondThoughtsC
    -- Riggght now.
    SceneTable["sp_a1_wakeupSecondThoughtsC01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_gantry_exposition_end()",
                delay = 2.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- SecondThoughtsD
    -- In case you thought to yourself, "I've missed the window of time to voice my reservations." Still open.
    SceneTable["sp_a1_wakeupSecondThoughtsD01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_gantry_exposition_end()",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- SheWillKillUs
    -- Probably ought to bring you up to speed on something right now.
    SceneTable["sp_a1_wakeupSheWillKillUs01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry20.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupSheWillKillUs02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1
    }

    -- In order to escape, we're going to have to go through HER chamber.
    SceneTable["sp_a1_wakeupSheWillKillUs02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry21.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupSheWillKillUs03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And she will probably kill us if, um, she's awake.
    SceneTable["sp_a1_wakeupSheWillKillUs03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosgantry22.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_gantry_exposition_end()",
                delay = 0.2
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- ThereSheIs
    -- There she is...
    SceneTable["sp_a1_wakeupThereSheIs01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber01.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupThereSheIs02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.2,
        queue = 1
    }

    -- What a nasty piece of work she was, honestly. Like a proper maniac.
    SceneTable["sp_a1_wakeupThereSheIs02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber06.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupThereSheIs03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You know who ended up, do you know who ended up taking her down in the end? You're not going to believe this. A human.
    SceneTable["sp_a1_wakeupThereSheIs03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber07.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupThereSheIs04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I know! I know, I wouldn't have believed it either.
    SceneTable["sp_a1_wakeupThereSheIs04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber08.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupThereSheIs05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Apparently this human escaped and nobody's seen him since.
    SceneTable["sp_a1_wakeupThereSheIs05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber09.vcd"),
        postdelay = 0.4,
        next = "sp_a1_wakeupThereSheIs06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Then there was a sort of long chunk of time where absolutely nothing happened and then there's us escaping now. So that's pretty much the whole story, you're up to speed. Don't touch anything.
    SceneTable["sp_a1_wakeupThereSheIs06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospheregladoschamber11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@DownTheStairsTrigger",
                input = "Enable",
                parameter = "",
                delay = 0.1
            },
            {
                entity = "@JumpDownTrigger",
                input = "Enable",
                parameter = "",
                delay = 0.3
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- WakeupOops
    -- Oh! Look at that. It's turning. Ominous. But probably fine. Long as it doesn't start moving up...
    SceneTable["sp_a1_wakeupWakeupOops01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_breakerroom_turn03.vcd"),
        postdelay = 0.3,
        next = "sp_a1_wakeupWakeupOops02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.0,
        queue = 1
    }

    -- Now, escape pod... escape pod...
    SceneTable["sp_a1_wakeupWakeupOops02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_breakerroom_turn02.vcd"),
        postdelay = 0.01,
        next = "sp_a1_wakeupWakeupOops03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.0
    }

    -- It's... It's moving up.
    SceneTable["sp_a1_wakeupWakeupOops03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_breakerroom_turn06.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupOops05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.0
    }

    -- Okay...
    SceneTable["sp_a1_wakeupWakeupOops05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherebreakerlift19.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupOops06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Okay! No, don't worry! Don't worry! I've got it I've got it I've got it! THIS should slow it down!
    SceneTable["sp_a1_wakeupWakeupOops06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherebreakerlift07.vcd"),
        postdelay = 0.5,
        next = "sp_a1_wakeupWakeupOops07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- No. Makes it go faster.
    SceneTable["sp_a1_wakeupWakeupOops07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherebreakerlift14.vcd"),
        postdelay = 1.0,
        next = "sp_a1_wakeupWakeupOops08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Uh oh.
    SceneTable["sp_a1_wakeupWakeupOops08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_breakerroom_turn04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- WakeupPartOneA
    -- Powerup initiated.
    SceneTable["sp_a1_wakeupWakeupPartOneA01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/wakeup_powerup01.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupWakeupPartOneA02",
        char = "announcer",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.8
    }

    -- Okay don't panic! Allright? Stop panicking! I can still stop this. Ahh. Oh there's a password.  It's fine. I'll just hack it. Not a problem... umm...
    SceneTable["sp_a1_wakeupWakeupPartOneA02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking08.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupPartOneA03",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- A...A...A...A...A... Umm... A.
    SceneTable["sp_a1_wakeupWakeupPartOneA03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking09.vcd"),
        postdelay = -3.6,
        next = "sp_a1_wakeupWakeupPartOneA04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- <BUZZER NOISE>
    SceneTable["sp_a1_wakeupWakeupPartOneA04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking12.vcd"),
        postdelay = 0.01,
        next = "sp_a1_wakeupWakeupPartOneA05",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Nope. Okay. A... A... A... A... A... C.
    SceneTable["sp_a1_wakeupWakeupPartOneA05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking10.vcd"),
        postdelay = -4.01,
        next = "sp_a1_wakeupWakeupPartOneA06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- <BUZZER NOISE>
    SceneTable["sp_a1_wakeupWakeupPartOneA06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking12.vcd"),
        postdelay = 0.01,
        next = "sp_a1_wakeupWakeupPartOneA07",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- No. Wait, did I do B? Do you have a pen? Start writing these down.
    SceneTable["sp_a1_wakeupWakeupPartOneA07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherepowerup12.vcd"),
        postdelay = -2.4,
        next = "sp_a1_wakeupWakeupPartOneA08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Powerup complete.
    SceneTable["sp_a1_wakeupWakeupPartOneA08"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/wakeup_powerup02.vcd"),
        postdelay = 0.01,
        next = "sp_a1_wakeupWakeupPartOneA09",
        char = "announcer",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Okay. Okay. Okay listen: New plan. Act natural. We've done nothing wrong.
    SceneTable["sp_a1_wakeupWakeupPartOneA09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking11.vcd"),
        postdelay = 0.2,
        next = "sp_a1_wakeupWakeupPartOneA10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hello!
    SceneTable["sp_a1_wakeupWakeupPartOneA10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherepowerup04.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupWakeupPartOneA11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh... It's you.
    SceneTable["sp_a1_wakeupWakeupPartOneA11"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/chellgladoswakeup01.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupWakeupPartOneA12",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- You KNOW her?
    SceneTable["sp_a1_wakeupWakeupPartOneA12"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_hacking03.vcd"),
        postdelay = -0.55,
        next = "sp_a1_wakeupWakeupPartOneA13",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- It's been a long time. How have you been?
    SceneTable["sp_a1_wakeupWakeupPartOneA13"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/chellgladoswakeup04.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupPartOneA15",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- I've been really busy being dead. You know, after you MURDERED ME.
    SceneTable["sp_a1_wakeupWakeupPartOneA15"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/chellgladoswakeup05.vcd"),
        postdelay = -5.2,
        next = "sp_a1_wakeupWakeupPartOneA16",
        char = "glados",
        fires = {
            {
                entity = "relay_start_claw_pickup",
                input = "trigger",
                parameter = "",
                delay = 3.9,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_wakeup_transport()",
                delay = 20.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- You did WHAT?
    SceneTable["sp_a1_wakeupWakeupPartOneA16"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/demospherepowerup07.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupWakeupPartOneA17",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Aggggh!
    SceneTable["sp_a1_wakeupWakeupPartOneA17"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_wheatley_ows_long03.vcd"),
        postdelay = 1.752,
        next = "sp_a1_wakeupWakeupPartOneA18",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh no! nonononono!
    SceneTable["sp_a1_wakeupWakeupPartOneA18"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/a1_wakeup_pinchergrab01.vcd"),
        postdelay = 0.5,
        next = "sp_a1_wakeupWakeupPartOneA19",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh no no no... No! Nooo!
    SceneTable["sp_a1_wakeupWakeupPartOneA19"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/a1_wakeup_pinchergrab02.vcd"),
        postdelay = 0.0,
        next = "sp_a1_wakeupWakeupPartOneA20",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- GAH!
    SceneTable["sp_a1_wakeupWakeupPartOneA20"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_wheatley_ows20.vcd"),
        postdelay = -0.3,
        next = "sp_a1_wakeupWakeupPartOneA21",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Okay. Look. We both said a lot of things that you're going to regret. But I think we can put our differences behind us. For science. You monster.
    SceneTable["sp_a1_wakeupWakeupPartOneA21"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/chellgladoswakeup06.vcd"),
        postdelay = 3.0,
        next = "sp_a1_wakeupWakeupPartOneA22",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- I will say, though, that since you went to all the trouble of waking me up, you must really, really love to test.
    SceneTable["sp_a1_wakeupWakeupPartOneA22"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/wakeup_outro01.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupPartOneA23",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- I love it too. There's just one small thing we need to take care of first.
    SceneTable["sp_a1_wakeupWakeupPartOneA23"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/wakeup_outro02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- WakeupTransport
    -- I will say, though, that since you went to all the trouble of waking me up, you must really, really love to test.
    SceneTable["sp_a1_wakeupWakeupTransport01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a1_wakeup_incinerator01.vcd"),
        postdelay = 0.1,
        next = "sp_a1_wakeupWakeupTransport02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- I love it, too. So let's get you a dual portal device and go do some science.
    SceneTable["sp_a1_wakeupWakeupTransport02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a1_wakeup_incinerator02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- YourMyRail
    -- I just now realized that I used to rely on my management rail to not fall into bottomless pits. And you're my rail now. And you can fall into bottomless pits. I'm rambling out of fear, but here's the point:
    SceneTable["sp_a1_wakeupYourMyRail01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a1_wakeup_catwalk03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_bts2                                        
if curMapName == "sp_a2_bts2" then
    -- JailbreakAlmostOut
    -- There's the exit! We're almost out of here!
    SceneTable["sp_sabotage_jailbreak2JailbreakAlmostOut01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_near_exit01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakBringingDown
    -- She's bringing the whole place down! Hurry!
    SceneTable["sp_sabotage_jailbreak2JailbreakBringingDown01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_near_exit02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.2,
        queue = 1,
        queuetimeout = 1.0
    }

    -- JailbreakComeOnComeOn
    -- Come on! Come on!
    SceneTable["sp_sabotage_jailbreak2JailbreakComeOnComeOn01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens23.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakGetInTheLift
    -- Get in the lift! Get in the lift!
    SceneTable["sp_sabotage_jailbreak2JailbreakGetInTheLift01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 1,
        queuepredelay = 0.2
    }

    -- JailbreakGetToElevatorNag
    -- HURRY! THIS WAY!
    SceneTable["sp_sabotage_jailbreak2JailbreakGetToElevatorNag01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 1.5,
        idle = true,
        idleminsecs = 2.500,
        idlemaxsecs = 4.000,
        idlegroup = "sp_sabotage_jailbreak2jailbreakgettoelevatornag",
        idleorderingroup = 1
    }

    -- HURRY! THIS WAY!
    SceneTable["sp_sabotage_jailbreak2JailbreakGetToElevatorNag02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_sabotage_jailbreak2jailbreakgettoelevatornag",
        idleorderingroup = 2
    }

    -- JailbreakGoGo
    -- Go! Go go go!
    SceneTable["sp_sabotage_jailbreak2JailbreakGoGo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakdooropens26.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakGunfire
    -- I heard gunfire! A bit late for this, but look out for gunfire! Probably too late at this point, but I have at least tried.
    SceneTable["sp_sabotage_jailbreak2JailbreakGunfire01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_trapped06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1,
        queueforcesecs = 2.0
    }

    -- JailbreakLookOutTurrets
    -- Turrets!
    SceneTable["sp_sabotage_jailbreak2JailbreakLookOutTurrets01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/jailbreakrun09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 0.0
    }

    -- JailbreakOutOfTrap
    -- You're okay! Great! Come on!
    SceneTable["sp_sabotage_jailbreak2JailbreakOutOfTrap01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_out_of_trap01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakThisWay
    -- This way! This way!
    SceneTable["sp_sabotage_jailbreak2JailbreakThisWay01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakTrappedWithTurrets
    -- AH!
    SceneTable["sp_sabotage_jailbreak2JailbreakTrappedWithTurrets01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_big_surprise01.vcd"),
        postdelay = 1.2,
        next = "sp_sabotage_jailbreak2JailbreakTrappedWithTurrets02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.2
    }

    -- What's going on in there?
    SceneTable["sp_sabotage_jailbreak2JailbreakTrappedWithTurrets02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_trapped03.vcd"),
        postdelay = 1.0,
        next = "sp_sabotage_jailbreak2JailbreakTrappedWithTurrets03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Can you get out?
    SceneTable["sp_sabotage_jailbreak2JailbreakTrappedWithTurrets03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_trapped02.vcd"),
        postdelay = 3.0,
        next = "sp_sabotage_jailbreak2JailbreakTrappedWithTurrets04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- We have to get you out of there!
    SceneTable["sp_sabotage_jailbreak2JailbreakTrappedWithTurrets04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_trapped01.vcd"),
        postdelay = 1.5,
        next = "sp_sabotage_jailbreak2JailbreakTrappedWithTurrets05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Try to make your way back out here!
    SceneTable["sp_sabotage_jailbreak2JailbreakTrappedWithTurrets05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_trapped05.vcd"),
        postdelay = 2.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- JailbreakWeMadeIt
    -- We made it we made it we made it we made it...
    SceneTable["sp_sabotage_jailbreak2JailbreakWeMadeIt01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_sabotage_jailbreak_elevator11.vcd"),
        postdelay = 3.5,
        next = "sp_sabotage_jailbreak2JailbreakWeMadeIt02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'll meet you on the other side!
    SceneTable["sp_sabotage_jailbreak2JailbreakWeMadeIt02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_a2_bts2_near_exit03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_leave_the_map_relay",
                input = "Trigger",
                parameter = "",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a2_fizzler_intro                     
if curMapName == "sp_a2_fizzler_intro" then
    -- Explosion
    -- Ohhh, no. The turbines again. Every inch of this facility needs my attention. I have to go.  Wait. This next test DOES require some explanation. Let me give you the fast version.
    SceneTable["sp_a2_fizzler_introExplosion01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_fizzler_intro04.vcd"),
        postdelay = 0.0,
        next = "sp_a2_fizzler_introExplosion02",
        char = "glados"
    }

    -- <fast gibberish>
    SceneTable["sp_a2_fizzler_introExplosion02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_fizzler_intro05.vcd"),
        postdelay = 0.01,
        next = "sp_a2_fizzler_introExplosion03",
        char = "glados"
    }

    -- There. If you have any questions, just remember what I said in slow motion. Test on your own recognizance, I'll be right back.
    SceneTable["sp_a2_fizzler_introExplosion03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_fizzler_intro06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados"
    }

    -- Start
    -- This next test involves emancipation grills. Remember? I told you about them in the last test area, that didn't have one.
    SceneTable["sp_a2_fizzler_introStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_fizzler_intro01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        predelay = 3.0
    }
end

-- sp_a2_laser_chaining                    
if curMapName == "sp_a2_laser_chaining" then
    -- End
    -- So. I thought about our dilemma, and I came up with a solution that I honestly think works out best for one of both of us.
    SceneTable["sp_a2_laser_chainingEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_dilemma01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- Well, you know the old formula: Comedy equals tragedy plus time. And you have been asleep for a while. So I guess it's actually pretty funny when you do the math.
    SceneTable["sp_a2_laser_chainingStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/sp_a2_column_blocker05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        predelay = 1.0
    }
end

-- sp_a2_triple_laser                      
if curMapName == "sp_a2_triple_laser" then
    -- End
    -- I think these test chambers look even better than they did before. It was easy, really. You just have to look at things objectively, see what you don't need anymore, and trim out the fat.
    SceneTable["sp_a2_triple_laserEnd01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/a2_triple_laser03.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- Start
    -- Federal regulations require me to warn you that this next test chamber... is looking pretty good.
    SceneTable["sp_a2_triple_laserStart01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/a2_triple_laser01.vcd"),
        postdelay = 0.3,
        next = "sp_a2_triple_laserStart02",
        char = "glados",
        predelay = 0.0
    }

    -- That's right. The facility is completely operational again.
    SceneTable["sp_a2_triple_laserStart02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/a2_triple_laser02.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "glados"
    }
end

-- sp_a4_finale2                           
if curMapName == "sp_a4_finale2" then
    -- TbeamBackInOne
    -- FOOL! You were a fool to come back, because I've trapped you again! Helpless. At my mercy. And I don't have any. You're at my nothing.
    SceneTable["sp_a4_finale2TbeamBackInOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_inbeamb01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TbeamBackInTwo
    -- Puppet master! You're a puppet in a play, and I hold all the strings! And cards, still. Strings in one hand, cards in the other.
    SceneTable["sp_a4_finale2TbeamBackInTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_inbeamc01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TbeamEscapeOne
    -- No wait, come back. Please. I was going somewhere with that.
    SceneTable["sp_a4_finale2TbeamEscapeOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_earlyexita01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TbeamEscapeThree
    -- Alright, fine. I'm not saying another word until you do it properly. I'm sick of this.
    SceneTable["sp_a4_finale2TbeamEscapeThree01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_earlyexitc01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TbeamEscapeTwo
    -- And again, not playing along. You're runing what are some really good speeches, actually.
    SceneTable["sp_a4_finale2TbeamEscapeTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_earlyexitb01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale2TbeamEscapeTwo02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Didn't even get to the good part yet. Twist ending.
    SceneTable["sp_a4_finale2TbeamEscapeTwo02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_earlyexitb02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale2TbeamEscapeTwo03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- So twisty you might even call it spinning. MOO HOO HA HA HA ignore that. Ignore the laughter.
    SceneTable["sp_a4_finale2TbeamEscapeTwo03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale02_beamtrap_earlyexitb03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- ScreenSmashes                           
-- Smash01
-- Aw. Bless your little primate brain. I'm not actually in the room with you. Technology. It's complicated. Can't hurt the big god face.
SceneTable["ScreenSmashesSmash0101"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash06.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash02
-- You know what I have too many of around here? Monitors. I was just thinking earlier today I wish I had fewer montors that were working. So you're actually helping me by smashing them.
SceneTable["ScreenSmashesSmash0202"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash11.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash03
-- To clarify, I was being facetious about wanting to rid of monitors. They're actually useful. So I do want them around. So if you could just avoid smashing them.
SceneTable["ScreenSmashesSmash0303"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash12.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash04
-- Yes, alright. This is getting tiresome. I'm surprised you haven't got anything better to do. I know I have. You've proven you can break screens. Proven. Factual. Well done. Aren't you little miss clever. Little miss smashy-smash.
SceneTable["ScreenSmashesSmash0404"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash13.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash05
-- Does it actually make you feel good when you do that? Because it's not impressive. Noone's impressed. It's just glass, isn't it. Fragile. A babay could smash one of them. It's not impressive.
SceneTable["ScreenSmashesSmash0505"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash15.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash06
-- You know, there are test subjects in Africa who don't even have monitors in their test chambers. Think of that before you break any more of them.
SceneTable["ScreenSmashesSmash0611"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash28.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash07
-- What is this, like a hobby for you now?  I mean, honestly, it's crazy! You've been running around for hours, I'm surprised you have the energy to smash screens willy nilly. I'd have a lie down if I were you. Have a nap.
SceneTable["ScreenSmashesSmash0706"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash16.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash08
-- Starting now wonder if you're not doing all this screen-breaking on purpose. Beginning to take it personally. It's like an insult to me.
SceneTable["ScreenSmashesSmash0807"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash20.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash09
-- Oh there goes another one. They're not Inexpensive. I'd juts like to point that out. It seems unfair to smash screens. You could give them to people. Instead of smashing them, unscrew them and give them to homeless people. I don't know what a homeless
SceneTable["ScreenSmashesSmash0908"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash21.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash10
-- It's not like I've got hordes of replacement monitors just lying around back here in the old warehouse that I can just wheel out an bolt back on. I didn't order in loads of spare monitors thinking some crazy woman was going to go around smashing them
SceneTable["ScreenSmashesSmash1009"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash30.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- Smash11
-- These are not your screens to break. Pure vandalism. You wouldn't do this if this was your house. If I came around to your house and smashed your television, you'd be furious. And rightly so. Unbelievable.
SceneTable["ScreenSmashesSmash1110"] = {
    vcd = CreateSceneEntity("scenes/npc/sphere03/bw_screen_smash32.vcd"),
    postdelay = 0.1,
    next = nil,
    char = "wheatley",
    noDingOff = true,
    noDingOn = true
}

-- sp_a4_finale4                           
if curMapName == "sp_a4_finale4" then
    -- BBBombHitA
    -- AH!
    SceneTable["sp_a4_finale4BBBombHitA01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_portal_opens_short07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BBButtonNags
    -- Go press the button! Go press it!
    SceneTable["sp_a4_finale4BBButtonNags01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags01.vcd"),
        postdelay = -1.2,
        next = "sp_a4_finale4BBButtonNags02",
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- Do not press that button!
    SceneTable["sp_a4_finale4BBButtonNags02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags03.vcd"),
        postdelay = -1.2,
        next = "sp_a4_finale4BBButtonNags03",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- We're so close! Go press the button!
    SceneTable["sp_a4_finale4BBButtonNags03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags09.vcd"),
        postdelay = -2.4,
        next = "sp_a4_finale4BBButtonNags04",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- No!
    SceneTable["sp_a4_finale4BBButtonNags04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags01.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags05",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Do not do it!
    SceneTable["sp_a4_finale4BBButtonNags05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags04.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags06",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- I forbid you to press it!
    SceneTable["sp_a4_finale4BBButtonNags06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags11.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags07",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Press it! Press the button!
    SceneTable["sp_a4_finale4BBButtonNags07"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags10.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags08",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Don't press the button!
    SceneTable["sp_a4_finale4BBButtonNags08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags08.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags09",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Press it!
    SceneTable["sp_a4_finale4BBButtonNags09"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags05.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags10",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Don't press it! COME BACK!
    SceneTable["sp_a4_finale4BBButtonNags10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags10.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags11",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Press the button!
    SceneTable["sp_a4_finale4BBButtonNags11"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags02.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags12",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- No!
    SceneTable["sp_a4_finale4BBButtonNags12"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBButtonNags13",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Do not press that button!
    SceneTable["sp_a4_finale4BBButtonNags13"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags05.vcd"),
        postdelay = 0.3,
        next = "sp_a4_finale4BBButtonNags14",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Do not do it!
    SceneTable["sp_a4_finale4BBButtonNags14"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags07.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBButtonNags15",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- DO press it.
    SceneTable["sp_a4_finale4BBButtonNags15"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_buttonnags07.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBButtonNags16",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Come back!
    SceneTable["sp_a4_finale4BBButtonNags16"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags09.vcd"),
        postdelay = 1.5,
        next = "sp_a4_finale4BBButtonNags17",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Do not press that button!
    SceneTable["sp_a4_finale4BBButtonNags17"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_no_nags06.vcd"),
        postdelay = 0.0,
        next = nil,
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- BBCore1Plugged
    -- Warning: Core corruption at 50 percent.
    SceneTable["sp_a4_finale4BBCore1Plugged01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_corruption03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBCore1Plugged02",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- Vent system compromised: Neurotoxin offline.
    SceneTable["sp_a4_finale4BBCore1Plugged02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_neurotoxin06.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBCore1Plugged03",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- Reactor explosion in four minutes.
    SceneTable["sp_a4_finale4BBCore1Plugged03"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_reactor02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "bossannouncer",
        fires = {
            {
                entity = "wheatley_continue_1",
                input = "trigger",
                parameter = "",
                delay = 1.6,
                fireatstart = true
            },
            {
                entity = "destruction_relay",
                input = "trigger",
                parameter = "",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBCore2Plugged
    -- Warning: Core corruption at 75 percent.
    SceneTable["sp_a4_finale4BBCore2Plugged01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_corruption04.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBCore2Plugged02",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- Reactor Explosion Timer destroyed.
    SceneTable["sp_a4_finale4BBCore2Plugged02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_reactor06.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBCore2Plugged03",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- Reactor Explosion Uncertainty Emergency Preemption Protocol initiated: This facility will self destruct in two minutes.
    SceneTable["sp_a4_finale4BBCore2Plugged03"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_reactor07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "bossannouncer",
        fires = {
            {
                entity = "wheatley_continue_2",
                input = "trigger",
                parameter = "",
                delay = 6.5,
                fireatstart = true
            },
            {
                entity = "world_relay",
                input = "trigger",
                parameter = "",
                delay = 6.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBCore3Plugged
    -- Warning: Core corruption at 100 percent.
    SceneTable["sp_a4_finale4BBCore3Plugged01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_corruption06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "bossannouncer",
        fires = {
            {
                entity = "wheatley_continue_3",
                input = "trigger",
                parameter = "",
                delay = 0.0,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBExtraDialog
    -- Remember when I first told you how to find that little portal thing you love so much? Thought you'd die on the way, if I'm honest. All the others did.
    SceneTable["sp_a4_finale4BBExtraDialog01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak07.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBExtraDialog02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.5
    }

    -- You didn't think you were the first, did you? {laughs} No. Fifth. No, I lie: Sixth. Perhaps it's best to leave it to your imagination what happened to the other five...
    SceneTable["sp_a4_finale4BBExtraDialog02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak08.vcd"),
        postdelay = 0.5,
        next = "sp_a4_finale4BBExtraDialog03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You know what? I think we're well past the point of tasteful restraint. So I'll tell you: they all died. Horrifically. Trying to get that portal device you're gripping in your meaty little fingers there.
    SceneTable["sp_a4_finale4BBExtraDialog03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak09.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBExtraDialog04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- But you were different weren't you? Good jumper. Problem solver. Clever. But ambitious. That's your Achilles Heel. Mine's-oh! Oh! Almost told you. Clever, clever girl. Again: brain damaged like a fox, you.
    SceneTable["sp_a4_finale4BBExtraDialog04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBExtraDialogB()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBExtraDialogB
    -- We've had some times, though, haven't we? Like that time I jumped off my management rail, not sure if I'd die or not when I did, and all you had to do was catch me? Annnd you didn't. Ohhhh. You remember that? I remember that. I remember that all the
    SceneTable["sp_a4_finale4BBExtraDialogB01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak11.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBExtraDialogB02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Or that time we accidentally turned her back on and we would have talked our way out of it. Oh! Except you forgot to tell me you'd murdered her. And that she needed you to live, so the only available vent for her rage would be good old crushable
    SceneTable["sp_a4_finale4BBExtraDialogB02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak12.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBExtraDialogB03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, remember the time I took over the facility? Greatest moment of my life, but you just wanted to leave. Didn't want to share in my success. Well, so you know, I'd be happy for you if you succeeded. Apart from right now, obviously.
    SceneTable["sp_a4_finale4BBExtraDialogB03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak13.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBExtraDialogB04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Am I being too vague? I'm being too vague. {clears throat} I despise you. I loathe you. You arrogant, smugly quiet, awful jumpsuited monster of a woman. You and your little potato friend. This place would have been a triumph if it wasn't for you!
    SceneTable["sp_a4_finale4BBExtraDialogB04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BBIntro
    -- Well, well, well. Welcome to MY LAIR! According to the control panel light up here, the entire building's going to self destruct in six minutes. Pretty sure it's a problem with the light. But in case it isn't, I'm going to have to kill you.
    SceneTable["sp_a4_finale4BBIntro01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_introb01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- So, let's call that three minutes, and then a minute break, which should leave a leisurely two minutes to figure out how to shut down whatever's starting all these fires. So anyway, that's the itinerary.
    SceneTable["sp_a4_finale4BBIntro02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_introb02.vcd"),
        postdelay = 0.3,
        next = "sp_a4_finale4BBIntro03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Also, I watched the tapes of you killing her, and I'm not going to make the same mistakes. Four part plan is this:
    SceneTable["sp_a4_finale4BBIntro03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_intro_all01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- One: No portal surfaces.
    SceneTable["sp_a4_finale4BBIntro04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_intro_all02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Two: Start the neurotoxin immediately.
    SceneTable["sp_a4_finale4BBIntro05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_intro_all03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro06",
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_neurotoxin_relay",
                input = "trigger",
                parameter = "",
                delay = 0.4,
                fireatstart = true
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Three: Bomb-proof shields for me. Leading directly into Four: Bombs. For throwing at you.
    SceneTable["sp_a4_finale4BBIntro06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_intro_all04.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro07",
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_shield_relay",
                input = "trigger",
                parameter = "",
                delay = 1.5,
                fireatstart = true
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- You know what, this plan is so good, I'm going to give you a sporting chance and turn off the neurotoxin. I'm joking. Of course. Goodbye.
    SceneTable["sp_a4_finale4BBIntro07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_intro_all05.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBIntro08",
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_bomb_relay",
                input = "trigger",
                parameter = "",
                delay = 5.0,
                fireatstart = true
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Neurotoxin level at capacity in five minutes.
    SceneTable["sp_a4_finale4BBIntro08"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_neurotoxin01.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "bossannouncer",
        fires = {
            {
                entity = "neurotoxin_relay",
                input = "trigger",
                parameter = "",
                fireatstart = true,
                delay = 3.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBPrePipeDest()",
                delay = 3.0
            }
        },
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- BBPostPipe
    -- No!
    SceneTable["sp_a4_finale4BBPostPipe01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break01.vcd"),
        postdelay = 1.0,
        next = "sp_a4_finale4BBPostPipe02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Um... That's an impression of you. Because you just fell into my trap. There. Just now. Ha. I wanted you to trick me into bursting that pipe. Seemingly trick me. Gives you false hope. Leads to overconfidence. Mistakes. Fatal missteps. All part of my
    SceneTable["sp_a4_finale4BBPostPipe02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBPostPipe03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, but I just... have made my actual first mistake... by telling you my plan. Just now. Grrr... Achilles heel. Armed with that knowledge, I imagine you won't even use the conversion gel. Oh fate! Oh cruel mistress.
    SceneTable["sp_a4_finale4BBPostPipe03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBPostPipe05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- That conversion gel has been sitting stagnant in that pipe for years. You'll probably get botulism portalling through it like that.
    SceneTable["sp_a4_finale4BBPostPipe05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break05.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBPostPipe06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And you'll probably get ringworm. And Athlete's Foot. And... Cholera. Or something... Horrible. It's gonna be even worse than if I'd just blown you up.
    SceneTable["sp_a4_finale4BBPostPipe06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break06.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBPostPipe07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- But it's not too late to avoid all of that by simply not using the gel. There you go, I said it. I gave away my plan. But I couldn't watch you hurt yourself like this.
    SceneTable["sp_a4_finale4BBPostPipe07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_whitegel_break07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBExtraDialogA()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBPrePipe
    -- Where are you going? Don't run! Don't run! The harder you breathe, the more neurotoxin you'll inhale. It's bloody clever. Devilish.
    SceneTable["sp_a4_finale4BBPrePipe01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_bombtaunts01.vcd"),
        postdelay = 1.0,
        next = "sp_a4_finale4BBPrePipe02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Still running. Alright. Looks tiring. Tell you what - you stop running and I'll stop bombing you... That seems fair.
    SceneTable["sp_a4_finale4BBPrePipe02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_bombtaunts02.vcd"),
        postdelay = 1.6,
        next = "sp_a4_finale4BBPrePipe03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Alright. Didn't go for that, I see. Knew I was lying. Point to you. Still inhaling neurotoxin, though. Point deducted.
    SceneTable["sp_a4_finale4BBPrePipe03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_bombtaunts03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBPrePipe04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Look out! I'm right behind you! No, of course I'm not. Saw through that. Forty feet tall, right in front of you. Not my greatest ruse. Still a giant robot, though.
    SceneTable["sp_a4_finale4BBPrePipe04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_bombtaunts11.vcd"),
        postdelay = 0.9,
        next = "sp_a4_finale4BBPrePipe05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Ohp! Where are you going? Nowhere. Not going anywhere. Got you trapped like a little jumpsuited rat.
    SceneTable["sp_a4_finale4BBPrePipe05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak01.vcd"),
        postdelay = 1.5,
        next = "sp_a4_finale4BBPrePipe06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, did you bring your little portal gun? Nothing to portal on here, luv. Just ten pounds of dead weight. About to be two hundred and ten. Fatty.
    SceneTable["sp_a4_finale4BBPrePipe06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak02.vcd"),
        postdelay = 1,
        next = "sp_a4_finale4BBPrePipe07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You're just delaying the inevitable. You can't run from my bombs forever. Well, you can if I keep aiming them poorly. But I'll get better as we go, and you'll just get tired.
    SceneTable["sp_a4_finale4BBPrePipe07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak03.vcd"),
        postdelay = 2,
        next = "sp_a4_finale4BBPrePipe08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- This would go a lot faster if you'd stay still. Then I'd have time to fix the facility. So one of us would live. No need to be selfish, luv.
    SceneTable["sp_a4_finale4BBPrePipe08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak05.vcd"),
        postdelay = 1,
        next = "sp_a4_finale4BBPrePipe09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I should congratulate you, by the way. I didn't actually think you'd make such a worthy opponent. Weren't you supposed to be brain damaged or something? Brain damaged like a fox.
    SceneTable["sp_a4_finale4BBPrePipe09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_pre_pipebreak06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBExtraDialogA()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBWakeupOneA
    -- Ahhh... Wha- What happened?
    SceneTable["sp_a4_finale4BBWakeupOneA01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa01.vcd"),
        postdelay = 0.4,
        next = "sp_a4_finale4BBWakeupOneA02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- What happened? What, what, what have you put onto me? What is that?
    SceneTable["sp_a4_finale4BBWakeupOneA02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneA03",
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_futbol_guard_relay2",
                input = "trigger",
                parameter = "",
                delay = 1.8,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on, {click click click} Ah, the bloody bombs are stuck on. Doesn't matter - I've reconfigured the shields. On we go.
    SceneTable["sp_a4_finale4BBWakeupOneA03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneA04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, it's a core you've put on me! Who told you to do that? Was it her? {as if he's looking around} It's just making me stronger, luv! It's a fool's errand!
    SceneTable["sp_a4_finale4BBWakeupOneA04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBExtraDialogA()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBWakeupOneB
    -- Ahhh... Wha- What happened?
    SceneTable["sp_a4_finale4BBWakeupOneB01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa01.vcd"),
        postdelay = 0.4,
        next = "sp_a4_finale4BBWakeupOneB02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- What happened? What, what, what have you put onto me? What is that?
    SceneTable["sp_a4_finale4BBWakeupOneB02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB03",
        char = "wheatley",
        fires = {
            {
                entity = "wheatley_futbol_guard_relay2",
                input = "trigger",
                parameter = "",
                delay = 1.8,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Hold on, {click click click} Ah, the bloody bombs are stuck on. Doesn't matter - I've reconfigured the shields. On we go.
    SceneTable["sp_a4_finale4BBWakeupOneB03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Oh, it's a core you've put on me! Who told you to do that? Was it her? {as if he's looking around} It's just making me stronger, luv! It's a fool's errand!
    SceneTable["sp_a4_finale4BBWakeupOneB04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa04.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Are you trying to weigh me down? Think I'll fall out of the ceiling? Won't work. I'm not just quite brilliant, I'm also quite strong. Biggest muscle in my body: my brain. Second biggest: My muscles. So, it's not going to work. Clearly.
    SceneTable["sp_a4_finale4BBWakeupOneB05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa05.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Did you put a virus in them? It's not going to work either. I've got a firewall, mate. Literally, actually, now that I look around. There appears to be a quite literal wall of fire around this place. Alarming.
    SceneTable["sp_a4_finale4BBWakeupOneB06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa06.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- In fact, I'm going to have to take a break for a minute. A partial break during which I'll stop the facility from exploding while still throwing bombs at you.
    SceneTable["sp_a4_finale4BBWakeupOneB07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa07.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Alright, then. Let us see... "Vital maintenance protocols." Wow, there are a lot of them. Should have looked into this earlier. Well, let's try this: {reading while typing} DO THEM. {failure buzzer}. Fair enough. Maybe it's a password.
    SceneTable["sp_a4_finale4BBWakeupOneB08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa08.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- A, A, A, A, A, A. {NNNT!} No. A, A, A, A, A, B. {NNNT!} Hold on, I've done both of these. Skip ahead. A, B, C... D, G, H.{DING!}
    SceneTable["sp_a4_finale4BBWakeupOneB09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupa09.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Hah! It bloody worked! Hacked. Properly. Properly hacked. I hacked it! Hah!
    SceneTable["sp_a4_finale4BBWakeupOneB10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale4_hackworked01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupOneB11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Now, let's... see here... Ah! "Reactor Core Emergency Heat Venting Protocols." Well, that's the problem right there, isn't it? "Emergency". Doesn't sound good. DELETE.
    SceneTable["sp_a4_finale4BBWakeupOneB11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale4_hackworked02.vcd"),
        postdelay = 0.4,
        next = "sp_a4_finale4BBWakeupOneB12",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Undelete, undelete! Where's the undelete button?
    SceneTable["sp_a4_finale4BBWakeupOneB12"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale4_hackworked03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- BBWakeupThree
    -- ahhhhEHHHHHH!
    SceneTable["sp_a4_finale4BBWakeupThree01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_portal_opens17.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Manual core replacement required.
    SceneTable["sp_a4_finale4BBWakeupThree02"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate01.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree03",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- Ohhh. I see. {chuckle}
    SceneTable["sp_a4_finale4BBWakeupThree03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_stalemate_intro01.vcd"),
        postdelay = -2.8,
        next = "sp_a4_finale4BBWakeupThree04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Substitute Core: Are you ready to start?
    SceneTable["sp_a4_finale4BBWakeupThree04"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate02.vcd"),
        postdelay = -1.5,
        next = "sp_a4_finale4BBWakeupThree05",
        char = "bossannouncer",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Yes! Come on!
    SceneTable["sp_a4_finale4BBWakeupThree05"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/potatos_sp_a4_finale4_stalemate05.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree06",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Corrupted Core: are you ready to start?
    SceneTable["sp_a4_finale4BBWakeupThree06"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate03.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree07",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- What do you think?
    SceneTable["sp_a4_finale4BBWakeupThree07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_stalemate_intro03.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree08",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Interpreting vague answer as YES.
    SceneTable["sp_a4_finale4BBWakeupThree08"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate04.vcd"),
        postdelay = -1.65,
        next = "sp_a4_finale4BBWakeupThree09",
        char = "bossannouncer",
        noDingOff = true,
        noDingOn = true
    }

    -- No! No! NONONO!
    SceneTable["sp_a4_finale4BBWakeupThree09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_stalemate_intro04.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree10",
        char = "wheatley",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Didn't pick up on my sarcasm...
    SceneTable["sp_a4_finale4BBWakeupThree10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_stalemate_intro05.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupThree11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Stalemate detected.
    SceneTable["sp_a4_finale4BBWakeupThree11"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate05.vcd"),
        postdelay = 2.3,
        next = "sp_a4_finale4BBWakeupThree12",
        char = "bossannouncer",
        fires = {
            {
                entity = "fire_relay",
                input = "trigger",
                parameter = "",
                delay = 0.5,
                fireatstart = true
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Fire detected in the Stalemate Resolution Annex. Extinguishing.
    SceneTable["sp_a4_finale4BBWakeupThree12"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate06.vcd"),
        postdelay = 4.0,
        next = "sp_a4_finale4BBWakeupThree13",
        char = "bossannouncer",
        fires = {
            {
                entity = "sprinkler_relay",
                input = "trigger",
                parameter = "",
                delay = 0.0
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "finale4_clear_portals()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Ah. That just cleans right off, does it? Would have been good to know. A little earlier.
    SceneTable["sp_a4_finale4BBWakeupThree13"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_stalemate_intro06.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupThree14",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Stalemate Resolution Associate: Please press the Stalemate Resolution Button.
    SceneTable["sp_a4_finale4BBWakeupThree14"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/bb_stalemate07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "bossannouncer",
        fires = {
            {
                entity = "stalemate_relay",
                input = "trigger",
                parameter = "",
                delay = 3.0,
                fireatstart = true
            },
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "BBButtonNags2()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- BBWakeupTwo
    -- Enough! I told you not to put these cores on me. But you don't listen, do you? Quiet. All the time. Quietly not listening to a word I say. Judging me. Silently. The worst kind.
    SceneTable["sp_a4_finale4BBWakeupTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- All I wanted to do was make everything better for me! All you had to do was solve a couple hundred simple tests for a few years. And you couldn't even let me have that, could you?
    SceneTable["sp_a4_finale4BBWakeupTwo02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb02.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Gotta go to space. Yeah. Gotta go to space.
    SceneTable["sp_a4_finale4BBWakeupTwo03"] = {
        vcd = CreateSceneEntity("scenes/npc/core01/babbleb25.vcd"),
        postdelay = 0.0,
        next = "sp_a4_finale4BBWakeupTwo04",
        char = "core01",
        noDingOff = true,
        noDingOn = true
    }

    -- Nobody is going to space, mate!
    SceneTable["sp_a4_finale4BBWakeupTwo04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb03.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- And another thing! You never caught me. I told you I could die falling off that rail. And you didn't catch me. You didn't even try. Oh, it's all becoming clear to me now. Find some dupe to break you out of cryosleep. Give him a sob story about escaping
    SceneTable["sp_a4_finale4BBWakeupTwo05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb04.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Then, when he's no more use to you, he has a little accident. "Falls" off his management rail.
    SceneTable["sp_a4_finale4BBWakeupTwo06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb05.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- You're in this together, aren't you? You've been playing me the whole time! First you make me think you're brain damaged! Then you convince me you're sworn enemies with
    SceneTable["sp_a4_finale4BBWakeupTwo07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb07.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Then, then, when I reluctantly assume the responsibility of running the place, you conveniently decide to run off together. Just when I need you most.
    SceneTable["sp_a4_finale4BBWakeupTwo08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb08.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'll bet there isn't even a problem with the facility, is there? There's no such thing as a "reactor core". That's not even fire coming out of the walls, is it? Cleverly placed lights and papier mache, I'll bet that's all it is.
    SceneTable["sp_a4_finale4BBWakeupTwo09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_finale04_wakeupb01.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo10",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- All those pieces of the ceiling that keep falling out? Probably actually pieces of the ceiling, I'll bet. That looked real. But it doesn't signify anything, is my point.
    SceneTable["sp_a4_finale4BBWakeupTwo10"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb10.vcd"),
        postdelay = 0.1,
        next = "sp_a4_finale4BBWakeupTwo11",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- But the real point is - oh, oh! You know what I've just remembered? Football! Kicking a ball around for fun. Cruel, obviously. Humans love it. Metaphor. Should have seen this coming.
    SceneTable["sp_a4_finale4BBWakeupTwo11"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/bw_a4_finale04_wakeupb11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a1_intro4                            
if curMapName == "sp_a1_intro4" then
    -- End
    -- Great work! Because this message is prerecorded, any observations related to  your performance are speculation on our part. Please disregard any undeserved compliments.
    SceneTable["sp_a1_intro4End01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber09.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- FutureStarter
    -- Congratulations. You have trapped yourself. Opening the door.
    SceneTable["sp_a1_intro4FutureStarter01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber11.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer"
    }
end

-- sp_a1_intro1                            
if curMapName == "sp_a1_intro1" then
    -- Fizzler_Intro
    -- Please note the incandescent particle field across the exit. This Aperture Science Material Emancipation Grill will vaporize any unauthorized equipment that passes through it.
    SceneTable["sp_a1_intro1Fizzler_Intro01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber08.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        queue = 1,
        queueforcesecs = 1.0
    }

    -- Fizzler_IntroB
    -- You have just passed through an Aperture Science Material Emancipation Grill, which vaporizes most Aperture Science equipment that touches it.
    SceneTable["sp_a1_intro1Fizzler_IntroB01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- WheatleyDrivingWall3rdHit
    -- Whew. There we go! Now I'll be honest, you are probably in no fit state to run this particular type of cognitive gauntlet.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/openingwallhitthree01.vcd"),
        postdelay = 5.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit02",
        char = "wheatley",
        fires = {
            {
                entity = "@glados",
                input = "runscriptcode",
                parameter = "sp_a1_intro_cognitive_gauntlet_over()",
                delay = 0.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- Alright, off you go!
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags01.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Go on. Just... March on through that hole.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags02.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Yeah, it's alright. Go ahead.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags03.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I know I've painted quite a grim picture of your chances. But if you simply stand here, we will both surely die.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags04.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- So, again, just... move along. On small step and everything.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags05.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Go on.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags06.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit08",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- On ya go.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit08"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags07.vcd"),
        postdelay = 4.0,
        next = "sp_a1_intro1WheatleyDrivingWall3rdHit09",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Your destination's probably not going to come meet us here. Is it? So go on.
    SceneTable["sp_a1_intro1WheatleyDrivingWall3rdHit09"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/container_ride_leave_nags08.vcd"),
        postdelay = 4.0,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- WheatleyJumpDown
    -- Good luck!
    SceneTable["sp_a1_intro1WheatleyJumpDown01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/openinggoodbye02.vcd"),
        postdelay = 0.00,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- WheatleyJumpOver
    -- That's the spirit!
    SceneTable["sp_a1_intro1WheatleyJumpOver01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/openinggoodbye01.vcd"),
        postdelay = 0.00,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- sp_a1_intro6                            
if curMapName == "sp_a1_intro6" then
    -- End
    -- Good work, future-starter! That said, if you are old, simpleminded or cripplingly irradiated in such a way that the future should not start with you, please return to your primitive post-apocalyptic t
    SceneTable["sp_a1_intro6End01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/prehub18.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        }
    }

    -- MidPoint
    -- If you are a non-employee who has discovered this facility amid the ruins of civilization, remember: Testing is the future, and the future starts with you.
    SceneTable["sp_a1_intro6MidPoint01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/prehub17.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer"
    }

    -- Start
    -- This next test applies the principles of momentum to movement through portals. If the laws of physics no longer apply in the future, God help you.
    SceneTable["sp_a1_intro6Start01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer"
    }
end

-- sp_a1_intro5                            
if curMapName == "sp_a1_intro5" then
    -- Start
    -- If the Enrichment Center is currently being bombarded with fireballs, meteorites, or other objects from space, please avoid unsheltered testing areas wherever a lack of shelter from space-debris DOES NOT appear to be a deliberate part of the test.
    SceneTable["sp_a1_intro5Start01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber02.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer"
    }
end

-- sp_a1_intro3                                      
if curMapName == "sp_a1_intro3" then
    -- AfterFall
    -- Hello?
    SceneTable["sp_intro_03AfterFall01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_AfterFallAlt06.vcd"),
        postdelay = 1.0,
        next = "sp_intro_03AfterFall02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        predelay = 1.2
    }

    -- Can you see the portal gun?
    SceneTable["sp_intro_03AfterFall02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_AfterFallAlt04.vcd"),
        postdelay = 1.5,
        next = "sp_intro_03AfterFall03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Also, are you alive? That's important, should have asked that first.
    SceneTable["sp_intro_03AfterFall03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_AfterFallAlt05.vcd"),
        postdelay = 0.3,
        next = "sp_intro_03AfterFall04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'm--do you know what I'm going to do? I'm going to work on the assumption that you're still alive and I'm just going to wait for you up ahead.
    SceneTable["sp_intro_03AfterFall04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_AfterFallAlt08.vcd"),
        postdelay = 0.5,
        next = "sp_intro_03AfterFall05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I'll wait--I'll wait one hour. Then I'll come back and, assuming I can locate your dead body, I'll bury you. Alright? Brilliant! Go team! See you in an hour! Hopefully! If you're not... dead.
    SceneTable["sp_intro_03AfterFall05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_AfterFallAlt09.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- MindTheGap
    -- Some emergency testing may require prolonged interaction with lethal military androids.  Rest assured that all lethal military androids have been taught to read and provided with one copy of the Laws of Robotics. To share.
    SceneTable["sp_intro_03MindTheGap01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcerglados"
    }

    -- MindTheGapFinish
    -- Good. If you feel that a lethal military android has not respected your rights as detailed in the Laws of Robotics, please note it on your self-reporting form. A future Aperture Science Entitlement Associate will initiate the appropriate
    SceneTable["sp_intro_03MindTheGapFinish01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/testchamber06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcerglados",
        fires = {
            {
                entity = "@transition_script",
                input = "runscriptcode",
                parameter = "TransitionReady()",
                delay = 0.00
            }
        },
        queue = 1
    }

    -- Start
    -- If the Earth is currently governed by a manner of animal-king, sentient cloud or other governing body that either refuses to or is incapable of listening to reason, the-BZZZT!
    SceneTable["sp_intro_03Start01"] = {
        vcd = CreateSceneEntity("scenes/npc/announcer/prehub46.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "announcer",
        noDingOff = true,
        predelay = 0.8
    }

    -- StartFall
    -- Whoa!
    SceneTable["sp_intro_03StartFall01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_intro06.vcd"),
        postdelay = 0.000,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- TestGlados
    -- I was going to kill you fast. With bullets. Or neurotoxin. But if you're going to pull stunts like this, it doesn't have to be fast. So you know. I'll take my time.
    SceneTable["sp_intro_03TestGlados01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/fgbwheatleyentrance10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- TestIdle
    -- Oops.
    SceneTable["sp_intro_03TestIdle01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer03.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idle = true,
        idlerandom = true,
        idlerepeat = true,
        idleminsecs = 0.300,
        idlemaxsecs = 1.500,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 1
    }

    -- That's funny, I don't feel corrupt. In fact, I feel pretty good.
    SceneTable["sp_intro_03TestIdle02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer04.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 2
    }

    -- Core transfer?
    SceneTable["sp_intro_03TestIdle03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer05.vcd"),
        postdelay = 0.1,
        next = "sp_intro_03TestIdle0301",
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 3,
        idleindex = 1
    }

    -- NAG CHAIN: Oh, you are kidding me.
    SceneTable["sp_intro_03TestIdle0301"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer06.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 4,
        idleunder = 1
    }

    -- No!
    SceneTable["sp_intro_03TestIdle05"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer07.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 5
    }

    -- Yes! You little worm!
    SceneTable["sp_intro_03TestIdle06"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer10.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 6
    }

    -- Don't do it.
    SceneTable["sp_intro_03TestIdle07"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer12.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 7
    }

    -- Not so fast!
    SceneTable["sp_intro_03TestIdle08"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_xfer14.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true,
        idlegroup = "sp_intro_03testidle",
        idleorderingroup = 8
    }

    -- TestOne
    -- You be quiet. All you've ever done is TALK. And all you've ever done is judge me. Silently. Now that I'm plugged into all the world's knowledge, I know that's the WORST KIND of judging!
    SceneTable["sp_intro_03TestOne01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/gladosbattle_xfer01.vcd"),
        postdelay = -2.3,
        next = "sp_intro_03TestOne02",
        char = "wheatley",
        fires = {
            {
                entity = "sampleentity1",
                input = "Trigger",
                parameter = "",
                delay = 2.0
            }
        },
        noDingOff = true,
        noDingOn = true
    }

    -- I'm actually asking. Because I have no idea.  He's not listed anywhere in the employee database.
    SceneTable["sp_intro_03TestOne02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_pre13.vcd"),
        postdelay = 0.00,
        next = "sp_intro_03TestOne03",
        char = "glados",
        talkover = true,
        noDingOff = true,
        noDingOn = true
    }

    -- Whatever he does, it isn't important enough for anyone to bother writing it down. For all I know, he doesn't even work here.
    SceneTable["sp_intro_03TestOne03"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_pre14.vcd"),
        postdelay = 0.00,
        next = nil,
        char = "glados",
        noDingOff = true,
        noDingOn = true
    }

    -- TestTwo
    -- Oh no, don't. Anyway, back to you two imbeciles killing me:
    SceneTable["sp_intro_03TestTwo01"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_pre16.vcd"),
        postdelay = {0.100, 3.330},
        next = "sp_intro_03TestTwo02",
        char = "glados",
        fires = {
            {
                entity = "random",
                input = "Trigger",
                parameter = "",
                delay = 1
            }
        },
        noDingOff = true,
        noDingOn = true,
        predelay = {0.000, 1.440},
        queue = 1,
        queuetimeout = 33
    }

    -- Wait here. Don't go anywhere. I'll be back.
    SceneTable["sp_intro_03TestTwo02"] = {
        vcd = CreateSceneEntity("scenes/npc/glados/gladosbattle_pre18.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "glados",
        fires = {
            {
                entity = "random2",
                input = "Trigger",
                parameter = "",
                delay = 2,
                fireatstart = true
            },
            {
                entity = "random1",
                input = "OnStartTouch",
                parameter = "GladosPlayVcd(10)",
                delay = 4
            }
        },
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- TestWheatley
    -- I talked my way onto the nanobot work crew rebuilding this shaft. They're REALLY small, so they have very tiny little brains. But there're a billion of 'em, so it's only a matter of time until ONE of them notices I'm the size of a planet.
    SceneTable["sp_intro_03TestWheatley01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/nanobotinto05.vcd"),
        postdelay = 0.1,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true,
        queue = 1
    }

    -- WheatleyReturns
    -- Hey hey! You made it!
    SceneTable["sp_intro_03WheatleyReturns01"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_intro12.vcd"),
        postdelay = 1,
        next = "sp_intro_03WheatleyReturns02",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- There should be a portal device on that podium over there.
    SceneTable["sp_intro_03WheatleyReturns02"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_intro09.vcd"),
        postdelay = 1,
        next = "sp_intro_03WheatleyReturns03",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- I can't see it though... Maybe it fell off. Do you want to go and have a quick look?
    SceneTable["sp_intro_03WheatleyReturns03"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_intro10.vcd"),
        postdelay = 3,
        next = "sp_intro_03WheatleyReturns04",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- It's alright. No, go on, just have a look about.
    SceneTable["sp_intro_03WheatleyReturns04"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_introAlt06.vcd"),
        postdelay = 3,
        next = "sp_intro_03WheatleyReturns05",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- No, that's right. Over by the podium, yeah.
    SceneTable["sp_intro_03WheatleyReturns05"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_introAlt08.vcd"),
        postdelay = 3,
        next = "sp_intro_03WheatleyReturns06",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- Just---if you just--okay, just stand by the podium and just look up.
    SceneTable["sp_intro_03WheatleyReturns06"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_introAlt09.vcd"),
        postdelay = 3,
        next = "sp_intro_03WheatleyReturns07",
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }

    -- That's it, no, that's it! Yeah.
    SceneTable["sp_intro_03WheatleyReturns07"] = {
        vcd = CreateSceneEntity("scenes/npc/sphere03/sp_intro_03_introAlt07.vcd"),
        postdelay = 3,
        next = nil,
        char = "wheatley",
        noDingOff = true,
        noDingOn = true
    }
end

-- SceneTableLookup
SceneTableLookup = SceneTableLookup or {}
SceneTableLookup[106] = "PreHub01AirSupplySuccess01"
SceneTableLookup[104] = "PreHub01BoldPersistent01"
SceneTableLookup[113] = "PreHub01BoxDropperEntry01"
SceneTableLookup[7] = "PreHub01Chamber01Entry01"
SceneTableLookup[10] = "PreHub01Chamber01GrillSpeech01"
SceneTableLookup[9] = "PreHub01Chamber01Success01"
SceneTableLookup[13] = "PreHub01Chamber02Entry01"
SceneTableLookup[15] = "PreHub01Chamber02Success01"
SceneTableLookup[16] = "PreHub01Chamber03Entry01"
SceneTableLookup[20] = "PreHub01Chamber04Entry01"
SceneTableLookup[21] = "PreHub01Chamber04Success01"
SceneTableLookup[100] = "PreHub01Compliment0101"
SceneTableLookup[114] = "PreHub01DualButtonOnePortalEntry01"
SceneTableLookup[116] = "PreHub01DualButtonOnePortalSuccessA01"
SceneTableLookup[115] = "PreHub01DualButtonOnePortalSuccessB01"
SceneTableLookup[107] = "PreHub01Meteors01"
SceneTableLookup[111] = "PreHub01PortalCarouselEntry01"
SceneTableLookup[112] = "PreHub01PortalCarouselSuccess01"
SceneTableLookup[0] = "PreHub01RelaxationVaultIntro01"
SceneTableLookup[103] = "PreHub01SafetyDevicesDisabled01"
SceneTableLookup[208] = "sp_incinerator_01ClearArms01"
SceneTableLookup[209] = "sp_incinerator_01Elevator01"
SceneTableLookup[205] = "sp_incinerator_01FirstSpeech01"
SceneTableLookup[204] = "sp_incinerator_01GotGun01"
SceneTableLookup[203] = "sp_incinerator_01GunRubbleDone01"
SceneTableLookup[200] = "sp_incinerator_01Landing01"
SceneTableLookup[202] = "sp_incinerator_01MoveGunRubble01"
SceneTableLookup[206] = "sp_incinerator_01MovePanel01"
SceneTableLookup[544] = "sp_incinerator_01NoClearArms01"
SceneTableLookup[543] = "sp_incinerator_01NoMovePanel02"
SceneTableLookup[207] = "sp_incinerator_01SecondSpeech01"
SceneTableLookup[201] = "sp_incinerator_01SeeGun01"
SceneTableLookup[211] = "sp_laser_redirect_introEnd01"
SceneTableLookup[210] = "sp_laser_redirect_introStart01"
SceneTableLookup[213] = "sp_laser_stairsEnd01"
SceneTableLookup[212] = "sp_laser_stairsStart01"
SceneTableLookup[215] = "sp_laser_dual_lasersEnd01"
SceneTableLookup[214] = "sp_laser_dual_lasersStart01"
SceneTableLookup[217] = "sp_laser_powered_liftEnd01"
SceneTableLookup[216] = "sp_laser_powered_liftStart01"
SceneTableLookup[219] = "sp_laser_over_gooEnd01"
SceneTableLookup[218] = "sp_laser_over_gooStart01"
SceneTableLookup[220] = "sp_laser_over_gooWaddle01"
SceneTableLookup[225] = "sp_catapult_introEnd01"
SceneTableLookup[221] = "sp_catapult_introStart01"
SceneTableLookup[465] = "sp_trust_flingElevatorStop01"
SceneTableLookup[458] = "sp_trust_flingEnd01"
SceneTableLookup[457] = "sp_trust_flingFlinged01"
SceneTableLookup[222] = "sp_trust_flingStart01"
SceneTableLookup[230] = "sp_unassisted_angle_flingStart01"
SceneTableLookup[235] = "sp_hole_in_the_skyEnd01"
SceneTableLookup[234] = "sp_hole_in_the_skyStart01"
SceneTableLookup[238] = "sp_bridge_introElevator01"
SceneTableLookup[237] = "sp_bridge_introEnd01"
SceneTableLookup[236] = "sp_bridge_introStart01"
SceneTableLookup[241] = "sp_shoot_through_wallEnd01"
SceneTableLookup[240] = "sp_shoot_through_wallStart01"
SceneTableLookup[223] = "sp_bridge_the_gapDoorBroken01"
SceneTableLookup[251] = "sp_bridge_the_gapEnd01"
SceneTableLookup[336] = "sp_bridge_the_gapHeyUpHere01"
SceneTableLookup[224] = "sp_bridge_the_gapLeave01"
SceneTableLookup[462] = "sp_bridge_the_gapStart01"
SceneTableLookup[246] = "sp_sphere_2nd_encounterDoorBreak01"
SceneTableLookup[248] = "sp_sphere_2nd_encounterEnd01"
SceneTableLookup[247] = "sp_sphere_2nd_encounterMeetup01"
SceneTableLookup[245] = "sp_sphere_2nd_encounterStart01"
SceneTableLookup[260] = "sp_turret_introStart01"
SceneTableLookup[265] = "sp_turret_training_advancedStart01"
SceneTableLookup[268] = "sp_turret_blocker_introEnd01"
SceneTableLookup[267] = "sp_turret_blocker_introStart01"
SceneTableLookup[496] = "sp_column_blockerElevatorOw01"
SceneTableLookup[495] = "sp_column_blockerElevatorStart01"
SceneTableLookup[547] = "sp_column_blockerEnd01"
SceneTableLookup[269] = "sp_column_blockerStart01"
SceneTableLookup[272] = "sp_laser_vs_turret_introEnd01"
SceneTableLookup[271] = "sp_laser_vs_turret_introStart01"
SceneTableLookup[274] = "sp_laser_relaysEnd01"
SceneTableLookup[273] = "sp_laser_relaysStart01"
SceneTableLookup[276] = "sp_ring_around_the_turretsEnd01"
SceneTableLookup[275] = "sp_ring_around_the_turretsStart01"
SceneTableLookup[335] = "sp_catapult_fling_sphere_peekBounceOne01"
SceneTableLookup[363] = "sp_catapult_fling_sphere_peekBounceThree01"
SceneTableLookup[362] = "sp_catapult_fling_sphere_peekBounceTwo01"
SceneTableLookup[280] = "sp_catapult_fling_sphere_peekEnd01"
SceneTableLookup[277] = "sp_catapult_fling_sphere_peekFailureOne01"
SceneTableLookup[279] = "sp_catapult_fling_sphere_peekFailureThree01"
SceneTableLookup[278] = "sp_catapult_fling_sphere_peekFailureTwo01"
SceneTableLookup[283] = "sp_turret_towerEnd01"
SceneTableLookup[285] = "sp_paint_jump_trampolineEnd01"
SceneTableLookup[284] = "sp_paint_jump_trampolineStart01"
SceneTableLookup[287] = "sp_paint_jump_redirect_bombEnd01"
SceneTableLookup[286] = "sp_paint_jump_redirect_bombStart01"
SceneTableLookup[288] = "sp_paint_jump_wall_jumpsStart01"
SceneTableLookup[289] = "sp_paint_jump_wall_jumps_gapStart01"
SceneTableLookup[290] = "sp_climb_for_losEnd01"
SceneTableLookup[291] = "sp_angled_bridgeStart01"
SceneTableLookup[295] = "sp_turret_islandsStart01"
SceneTableLookup[297] = "sp_catapult_courseEnd01"
SceneTableLookup[296] = "sp_catapult_courseStart01"
SceneTableLookup[299] = "sp_laserfield_introStart01"
SceneTableLookup[308] = "sp_sabotage_jailbreakJailbreakAhh01"
SceneTableLookup[313] = "sp_sabotage_jailbreakJailbreakAlmostThere01"
SceneTableLookup[507] = "sp_sabotage_jailbreakJailbreakBridgeDisappear01"
SceneTableLookup[305] = "sp_sabotage_jailbreakJailbreakClosing01"
SceneTableLookup[314] = "sp_sabotage_jailbreakJailbreakDestroying01"
SceneTableLookup[500] = "sp_sabotage_jailbreakJailbreakDoorClosing01"
SceneTableLookup[440] = "sp_sabotage_jailbreakJailbreakElevatorStart01"
SceneTableLookup[307] = "sp_sabotage_jailbreakJailbreakFakeFail01"
SceneTableLookup[306] = "sp_sabotage_jailbreakJailbreakFakeTest01"
SceneTableLookup[502] = "sp_sabotage_jailbreakJailbreakGoGoGoNag01"
SceneTableLookup[311] = "sp_sabotage_jailbreakJailbreakGottaGo01"
SceneTableLookup[309] = "sp_sabotage_jailbreakJailbreakHeadsUp01"
SceneTableLookup[497] = "sp_sabotage_jailbreakJailbreakHeyLady01"
SceneTableLookup[506] = "sp_sabotage_jailbreakJailbreakHowStupid01"
SceneTableLookup[498] = "sp_sabotage_jailbreakJailbreakICanHearYou01"
SceneTableLookup[310] = "sp_sabotage_jailbreakJailbreakJumpDown01"
SceneTableLookup[501] = "sp_sabotage_jailbreakJailbreakKeepOnWalkway01"
SceneTableLookup[505] = "sp_sabotage_jailbreakJailbreakLastTestDeer01"
SceneTableLookup[503] = "sp_sabotage_jailbreakJailbreakLastTestIntro01"
SceneTableLookup[504] = "sp_sabotage_jailbreakJailbreakLastTestMain01"
SceneTableLookup[499] = "sp_sabotage_jailbreakJailbreakRunNag01"
SceneTableLookup[301] = "sp_sabotage_jailbreakJailbreakStart01"
SceneTableLookup[312] = "sp_sabotage_jailbreakJailbreakTurrets01"
SceneTableLookup[302] = "sp_sabotage_jailbreakJailbreakWhoah01"
SceneTableLookup[303] = "sp_sabotage_jailbreakJailbreakWhoahAlt01"
SceneTableLookup[550] = "sp_sabotage_jailbreakStart01"
SceneTableLookup[315] = "sp_sabotage_darknessDarknessIntro02"
SceneTableLookup[445] = "sp_sabotage_darknessghoststory01"
SceneTableLookup[446] = "sp_sabotage_darknesssmellyhuman0101"
SceneTableLookup[447] = "sp_sabotage_darknesssmellyhuman0201"
SceneTableLookup[448] = "sp_sabotage_darknesssmellyhuman0301"
SceneTableLookup[449] = "sp_sabotage_darknesssmellyhuman0401"
SceneTableLookup[450] = "sp_sabotage_darknesssmellyhuman0501"
SceneTableLookup[404] = "sp_sabotage_darknesssp_sabotage_darkness_node55001"
SceneTableLookup[405] = "sp_sabotage_darknesssp_sabotage_darkness_node55101"
SceneTableLookup[406] = "sp_sabotage_darknesssp_sabotage_darkness_node55201"
SceneTableLookup[407] = "sp_sabotage_darknesssp_sabotage_darkness_node55301"
SceneTableLookup[408] = "sp_sabotage_darknesssp_sabotage_darkness_node55501"
SceneTableLookup[409] = "sp_sabotage_darknesssp_sabotage_darkness_node55601"
SceneTableLookup[410] = "sp_sabotage_darknesssp_sabotage_darkness_node55701"
SceneTableLookup[411] = "sp_sabotage_darknesssp_sabotage_darkness_node55801"
SceneTableLookup[412] = "sp_sabotage_darknesssp_sabotage_darkness_node55901"
SceneTableLookup[413] = "sp_sabotage_darknesssp_sabotage_darkness_node56001"
SceneTableLookup[414] = "sp_sabotage_darknesssp_sabotage_darkness_node56101"
SceneTableLookup[415] = "sp_sabotage_darknesssp_sabotage_darkness_node56201"
SceneTableLookup[416] = "sp_sabotage_darknesssp_sabotage_darkness_node56401"
SceneTableLookup[417] = "sp_sabotage_darknesssp_sabotage_darkness_node56501"
SceneTableLookup[419] = "sp_sabotage_darknesssp_sabotage_darkness_node56701"
SceneTableLookup[420] = "sp_sabotage_darknesssp_sabotage_darkness_node56801"
SceneTableLookup[421] = "sp_sabotage_darknesssp_sabotage_darkness_node56901"
SceneTableLookup[422] = "sp_sabotage_darknesssp_sabotage_darkness_node57001"
SceneTableLookup[423] = "sp_sabotage_darknesssp_sabotage_darkness_node57101"
SceneTableLookup[425] = "sp_sabotage_darknesssp_sabotage_darkness_node57301"
SceneTableLookup[426] = "sp_sabotage_darknesssp_sabotage_darkness_node57401"
SceneTableLookup[427] = "sp_sabotage_darknesssp_sabotage_darkness_node57501"
SceneTableLookup[429] = "sp_sabotage_darknesssp_sabotage_darkness_node57701"
SceneTableLookup[430] = "sp_sabotage_darknesssp_sabotage_darkness_node59001"
SceneTableLookup[431] = "sp_sabotage_darknesssp_sabotage_darkness_node60001"
SceneTableLookup[432] = "sp_sabotage_darknesssp_sabotage_darkness_node60101"
SceneTableLookup[433] = "sp_sabotage_darknesssp_sabotage_darkness_node60201"
SceneTableLookup[434] = "sp_sabotage_darknesssp_sabotage_darkness_node61001"
SceneTableLookup[435] = "sp_sabotage_darknesssp_sabotage_darkness_node61101"
SceneTableLookup[436] = "sp_sabotage_darknesssp_sabotage_darkness_node62001"
SceneTableLookup[320] = "sp_sabotage_darknessUhOh01"
SceneTableLookup[582] = "sp_sabotage_factoryBigPotato01"
SceneTableLookup[325] = "sp_sabotage_factorycleanroom01"
SceneTableLookup[327] = "sp_sabotage_factorydefectivetesting01"
SceneTableLookup[518] = "sp_sabotage_factoryFactoryAlmostThere01"
SceneTableLookup[520] = "sp_sabotage_factoryFactoryControlDoorHackIntro01"
SceneTableLookup[521] = "sp_sabotage_factoryFactoryControlRoomHackSuccess01"
SceneTableLookup[534] = "sp_sabotage_factoryFactoryDefectiveTurretBringOne02"
SceneTableLookup[535] = "sp_sabotage_factoryFactoryDefectiveTurretBringTwo01"
SceneTableLookup[540] = "sp_sabotage_factoryFactoryEnterScannerWithTurretNoHint01"
SceneTableLookup[522] = "sp_sabotage_factoryFactoryFirstTurretPulled01"
SceneTableLookup[516] = "sp_sabotage_factoryFactoryFollowMe01"
SceneTableLookup[519] = "sp_sabotage_factoryFactoryScannerIntro01"
SceneTableLookup[541] = "sp_sabotage_factoryFactoryShoutout01"
SceneTableLookup[538] = "sp_sabotage_factoryFactorySuccessNoHint01"
SceneTableLookup[539] = "sp_sabotage_factoryFactorySuccessWithHint01"
SceneTableLookup[517] = "sp_sabotage_factoryFactoryTahDah01"
SceneTableLookup[523] = "sp_sabotage_factoryFactoryThinkNagA01"
SceneTableLookup[524] = "sp_sabotage_factoryFactoryThinkNagB02"
SceneTableLookup[525] = "sp_sabotage_factoryFactoryThinkNagC08"
SceneTableLookup[526] = "sp_sabotage_factoryFactoryThinkNagD09"
SceneTableLookup[527] = "sp_sabotage_factoryFactoryThinkNagE10"
SceneTableLookup[528] = "sp_sabotage_factoryFactoryThinkNagF11"
SceneTableLookup[529] = "sp_sabotage_factoryFactoryThinkNagG12"
SceneTableLookup[530] = "sp_sabotage_factoryFactoryThinkNagH13"
SceneTableLookup[531] = "sp_sabotage_factoryFactoryThinkNagI14"
SceneTableLookup[515] = "sp_sabotage_factoryFactoryWheatleyHey01"
SceneTableLookup[532] = "sp_sabotage_factoryFactoryWhereAreYouGoing01"
SceneTableLookup[533] = "sp_sabotage_factoryFactoryWhereAreYouGoingTwo01"
SceneTableLookup[323] = "sp_sabotage_factoryliveturret01"
SceneTableLookup[326] = "sp_sabotage_factorynondefectivetesting01"
SceneTableLookup[321] = "sp_sabotage_factoryredemption01"
SceneTableLookup[615] = "sp_sabotage_factoryRedemptionBabbleA01"
SceneTableLookup[616] = "sp_sabotage_factoryRedemptionBabbleB01"
SceneTableLookup[617] = "sp_sabotage_factoryRedemptionBabbleC01"
SceneTableLookup[618] = "sp_sabotage_factoryRedemptionBabbleD01"
SceneTableLookup[619] = "sp_sabotage_factoryRedemptionBabbleE01"
SceneTableLookup[620] = "sp_sabotage_factoryRedemptionBabbleF01"
SceneTableLookup[621] = "sp_sabotage_factoryRedemptionBabbleG01"
SceneTableLookup[622] = "sp_sabotage_factoryRedemptionBabbleH01"
SceneTableLookup[613] = "sp_sabotage_factoryRedemptionDie01"
SceneTableLookup[614] = "sp_sabotage_factoryRedemptionPickedUp01"
SceneTableLookup[324] = "sp_sabotage_factoryridingliveturret01"
SceneTableLookup[322] = "sp_sabotage_factoryridingredemption01"
SceneTableLookup[441] = "sp_sabotage_factorysp_sabotage_diditwork01"
SceneTableLookup[364] = "sp_sabotage_factorysp_sabotage_factory_100001"
SceneTableLookup[365] = "sp_sabotage_factorysp_sabotage_factory_100101"
SceneTableLookup[366] = "sp_sabotage_factorysp_sabotage_factory_100201"
SceneTableLookup[367] = "sp_sabotage_factorysp_sabotage_factory_100301"
SceneTableLookup[368] = "sp_sabotage_factorysp_sabotage_factory_100401"
SceneTableLookup[369] = "sp_sabotage_factorysp_sabotage_factory_100501"
SceneTableLookup[370] = "sp_sabotage_factorysp_sabotage_factory_110101"
SceneTableLookup[371] = "sp_sabotage_factorysp_sabotage_factory_110401"
SceneTableLookup[372] = "sp_sabotage_factorysp_sabotage_factory_200001"
SceneTableLookup[373] = "sp_sabotage_factorysp_sabotage_factory_201501"
SceneTableLookup[374] = "sp_sabotage_factorysp_sabotage_factory_202001"
SceneTableLookup[375] = "sp_sabotage_factorysp_sabotage_factory_202501"
SceneTableLookup[376] = "sp_sabotage_factorysp_sabotage_factory_203001"
SceneTableLookup[401] = "sp_sabotage_factorysp_sabotage_factory_203501"
SceneTableLookup[402] = "sp_sabotage_factorysp_sabotage_factory_204001"
SceneTableLookup[377] = "sp_sabotage_factorysp_sabotage_factory_204501"
SceneTableLookup[378] = "sp_sabotage_factorysp_sabotage_factory_205001"
SceneTableLookup[379] = "sp_sabotage_factorysp_sabotage_factory_205501"
SceneTableLookup[380] = "sp_sabotage_factorysp_sabotage_factory_206001"
SceneTableLookup[381] = "sp_sabotage_factorysp_sabotage_factory_207001"
SceneTableLookup[399] = "sp_sabotage_factorysp_sabotage_factory_207501"
SceneTableLookup[382] = "sp_sabotage_factorysp_sabotage_factory_209501"
SceneTableLookup[383] = "sp_sabotage_factorysp_sabotage_factory_210501"
SceneTableLookup[443] = "sp_sabotage_factorysp_sabotage_hack_interrupt01"
SceneTableLookup[444] = "sp_sabotage_factorysp_sabotage_hack_outdoor01"
SceneTableLookup[442] = "sp_sabotage_factorysp_sabotage_reached_hacking_spot01"
SceneTableLookup[439] = "sp_sabotage_factorysp_sabotage_redemption01"
SceneTableLookup[583] = "sp_sabotage_factoryVolcano01"
SceneTableLookup[584] = "sp_sabotage_factoryVolcanoB02"
SceneTableLookup[569] = "sp_a2_bts5ToxinCutAll01"
SceneTableLookup[568] = "sp_a2_bts5ToxinCutFive01"
SceneTableLookup[567] = "sp_a2_bts5ToxinCutFour01"
SceneTableLookup[565] = "sp_a2_bts5ToxinCutOffFrontOfRoom01"
SceneTableLookup[566] = "sp_a2_bts5ToxinCutOne01"
SceneTableLookup[564] = "sp_a2_bts5ToxinDoorIsNowOpen01"
SceneTableLookup[570] = "sp_a2_bts5ToxinIntoTube01"
SceneTableLookup[563] = "sp_a2_bts5ToxinTheDoorIsLocked01"
SceneTableLookup[562] = "sp_a2_bts5TurretDestructionOurHandiwork01"
SceneTableLookup[561] = "sp_a2_bts5WheatleyGreetsYou01"
SceneTableLookup[388] = "sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100001"
SceneTableLookup[389] = "sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100101"
SceneTableLookup[390] = "sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100201"
SceneTableLookup[391] = "sp_sabotage_panel_sneaksp_sabotage_panel_sneak_100301"
SceneTableLookup[392] = "sp_sabotage_tube_rideStartTubeRide01"
SceneTableLookup[393] = "sp_sabotage_tube_rideTubeRideUhOh01"
SceneTableLookup[551] = "sp_a2_pit_flingsEnd01"
SceneTableLookup[460] = "sp_a2_pit_flingsStart01"
SceneTableLookup[461] = "sp_a2_ricochetEnd01"
SceneTableLookup[631] = "sp_a2_ricochetFutureStarter01"
SceneTableLookup[459] = "sp_a2_ricochetStart01"
SceneTableLookup[464] = "sp_a2_pull_the_rugEnd01"
SceneTableLookup[463] = "sp_a2_pull_the_rugStart01"
SceneTableLookup[479] = "sp_a1_intro7BamSecretPanel01"
SceneTableLookup[470] = "sp_a1_intro7ComeThroughNag01"
SceneTableLookup[480] = "sp_a1_intro7GloriousFreedom01"
SceneTableLookup[466] = "sp_a1_intro7HeyUpHere01"
SceneTableLookup[578] = "sp_a1_intro7HoboTurretPass01"
SceneTableLookup[473] = "sp_a1_intro7Impact01"
SceneTableLookup[471] = "sp_a1_intro7ManagementRail01"
SceneTableLookup[477] = "sp_a1_intro7NoWatching01"
SceneTableLookup[481] = "sp_a1_intro7NoWatchingNag01"
SceneTableLookup[472] = "sp_a1_intro7OnThree01"
SceneTableLookup[475] = "sp_a1_intro7PickedUp01"
SceneTableLookup[572] = "sp_a1_intro7PickedUpDuringNotDead01"
SceneTableLookup[571] = "sp_a1_intro7PickedUpFast01"
SceneTableLookup[577] = "sp_a1_intro7PickedUpTwo01"
SceneTableLookup[474] = "sp_a1_intro7PickMeUpNag01"
SceneTableLookup[476] = "sp_a1_intro7PlugMeInNag01"
SceneTableLookup[469] = "sp_a1_intro7PopPortal01"
SceneTableLookup[468] = "sp_a1_intro7PopPortalNag01"
SceneTableLookup[628] = "sp_a1_intro7Start01"
SceneTableLookup[478] = "sp_a1_intro7TurnAroundNow01"
SceneTableLookup[467] = "sp_a1_intro7YouFoundIt01"
SceneTableLookup[487] = "sp_a1_wakeupChamberDoorOpen01"
SceneTableLookup[490] = "sp_a1_wakeupComeThroughHere01"
SceneTableLookup[491] = "sp_a1_wakeupDoNotLookDown01"
SceneTableLookup[493] = "sp_a1_wakeupDoNotTouch01"
SceneTableLookup[489] = "sp_a1_wakeupDownTheStairs01"
SceneTableLookup[579] = "sp_a1_wakeupFalling01"
SceneTableLookup[581] = "sp_a1_wakeupJumpNags01"
SceneTableLookup[580] = "sp_a1_wakeupLanded01"
SceneTableLookup[585] = "sp_a1_wakeupLetsGoIn01"
SceneTableLookup[494] = "sp_a1_wakeupLightsOn01"
SceneTableLookup[492] = "sp_a1_wakeupMainBreakerRoom01"
SceneTableLookup[483] = "sp_a1_wakeupSecondThoughtsA01"
SceneTableLookup[484] = "sp_a1_wakeupSecondThoughtsB01"
SceneTableLookup[485] = "sp_a1_wakeupSecondThoughtsC01"
SceneTableLookup[486] = "sp_a1_wakeupSecondThoughtsD01"
SceneTableLookup[482] = "sp_a1_wakeupSheWillKillUs01"
SceneTableLookup[488] = "sp_a1_wakeupThereSheIs01"
SceneTableLookup[542] = "sp_a1_wakeupWakeupOops01"
SceneTableLookup[589] = "sp_a1_wakeupWakeupPartOneA01"
SceneTableLookup[590] = "sp_a1_wakeupWakeupTransport01"
SceneTableLookup[586] = "sp_a1_wakeupYourMyRail01"
SceneTableLookup[575] = "sp_sabotage_jailbreak2JailbreakAlmostOut01"
SceneTableLookup[576] = "sp_sabotage_jailbreak2JailbreakBringingDown01"
SceneTableLookup[514] = "sp_sabotage_jailbreak2JailbreakComeOnComeOn01"
SceneTableLookup[510] = "sp_sabotage_jailbreak2JailbreakGetInTheLift01"
SceneTableLookup[509] = "sp_sabotage_jailbreak2JailbreakGetToElevatorNag01"
SceneTableLookup[513] = "sp_sabotage_jailbreak2JailbreakGoGo01"
SceneTableLookup[574] = "sp_sabotage_jailbreak2JailbreakGunfire01"
SceneTableLookup[508] = "sp_sabotage_jailbreak2JailbreakLookOutTurrets01"
SceneTableLookup[587] = "sp_sabotage_jailbreak2JailbreakOutOfTrap01"
SceneTableLookup[512] = "sp_sabotage_jailbreak2JailbreakThisWay01"
SceneTableLookup[573] = "sp_sabotage_jailbreak2JailbreakTrappedWithTurrets01"
SceneTableLookup[511] = "sp_sabotage_jailbreak2JailbreakWeMadeIt01"
SceneTableLookup[546] = "sp_a2_fizzler_introExplosion01"
SceneTableLookup[545] = "sp_a2_fizzler_introStart01"
SceneTableLookup[552] = "sp_a2_laser_chainingEnd01"
SceneTableLookup[548] = "sp_a2_laser_chainingStart01"
SceneTableLookup[549] = "sp_a2_triple_laserEnd01"
SceneTableLookup[282] = "sp_a2_triple_laserStart01"
SceneTableLookup[557] = "sp_a4_finale2TbeamBackInOne01"
SceneTableLookup[559] = "sp_a4_finale2TbeamBackInTwo01"
SceneTableLookup[556] = "sp_a4_finale2TbeamEscapeOne01"
SceneTableLookup[560] = "sp_a4_finale2TbeamEscapeThree01"
SceneTableLookup[558] = "sp_a4_finale2TbeamEscapeTwo01"
SceneTableLookup[601] = "ScreenSmashesSmash0101"
SceneTableLookup[602] = "ScreenSmashesSmash0202"
SceneTableLookup[603] = "ScreenSmashesSmash0303"
SceneTableLookup[604] = "ScreenSmashesSmash0404"
SceneTableLookup[605] = "ScreenSmashesSmash0505"
SceneTableLookup[606] = "ScreenSmashesSmash0611"
SceneTableLookup[607] = "ScreenSmashesSmash0706"
SceneTableLookup[608] = "ScreenSmashesSmash0807"
SceneTableLookup[609] = "ScreenSmashesSmash0908"
SceneTableLookup[610] = "ScreenSmashesSmash1009"
SceneTableLookup[611] = "ScreenSmashesSmash1110"
SceneTableLookup[596] = "sp_a4_finale4BBBombHitA01"
SceneTableLookup[612] = "sp_a4_finale4BBButtonNags01"
SceneTableLookup[633] = "sp_a4_finale4BBCore1Plugged01"
SceneTableLookup[634] = "sp_a4_finale4BBCore2Plugged01"
SceneTableLookup[635] = "sp_a4_finale4BBCore3Plugged01"
SceneTableLookup[594] = "sp_a4_finale4BBExtraDialog01"
SceneTableLookup[595] = "sp_a4_finale4BBExtraDialogB01"
SceneTableLookup[591] = "sp_a4_finale4BBIntro01"
SceneTableLookup[593] = "sp_a4_finale4BBPostPipe01"
SceneTableLookup[592] = "sp_a4_finale4BBPrePipe01"
SceneTableLookup[597] = "sp_a4_finale4BBWakeupOneA01"
SceneTableLookup[598] = "sp_a4_finale4BBWakeupOneB01"
SceneTableLookup[600] = "sp_a4_finale4BBWakeupThree01"
SceneTableLookup[599] = "sp_a4_finale4BBWakeupTwo01"
SceneTableLookup[555] = "sp_a1_intro4End01"
SceneTableLookup[632] = "sp_a1_intro4FutureStarter01"
SceneTableLookup[553] = "sp_a1_intro1Fizzler_Intro01"
SceneTableLookup[630] = "sp_a1_intro1Fizzler_IntroB01"
SceneTableLookup[359] = "sp_a1_intro1WheatleyDrivingWall3rdHit01"
SceneTableLookup[361] = "sp_a1_intro1WheatleyJumpDown01"
SceneTableLookup[360] = "sp_a1_intro1WheatleyJumpOver01"
SceneTableLookup[627] = "sp_a1_intro6End01"
SceneTableLookup[626] = "sp_a1_intro6MidPoint01"
SceneTableLookup[625] = "sp_a1_intro6Start01"
SceneTableLookup[629] = "sp_a1_intro5Start01"
SceneTableLookup[318] = "sp_intro_03AfterFall01"
SceneTableLookup[623] = "sp_intro_03MindTheGap01"
SceneTableLookup[624] = "sp_intro_03MindTheGapFinish01"
SceneTableLookup[554] = "sp_intro_03Start01"
SceneTableLookup[317] = "sp_intro_03StartFall01"
SceneTableLookup[537] = "sp_intro_03TestGlados01"
SceneTableLookup[403] = "sp_intro_03TestIdle01"
SceneTableLookup[341] = "sp_intro_03TestOne01"
SceneTableLookup[342] = "sp_intro_03TestTwo01"
SceneTableLookup[536] = "sp_intro_03TestWheatley01"
SceneTableLookup[316] = "sp_intro_03WheatleyReturns01"
-- MapBspConversion
MapBspConversion = MapBspConversion or {}
MapBspConversion["sp_a2_intro"] = "sp_incinerator_01"
MapBspConversion["sp_a2_laser_intro"] = "sp_laser_redirect_intro"
MapBspConversion["sp_a2_laser_stairs"] = "sp_laser_stairs"
MapBspConversion["sp_a2_dual_lasers"] = "sp_laser_dual_lasers"
MapBspConversion["sp_a2_laser_over_goo"] = "sp_laser_over_goo"
MapBspConversion["sp_a2_catapult_intro"] = "sp_catapult_intro"
MapBspConversion["sp_a2_trust_fling"] = "sp_trust_fling"
MapBspConversion["sp_a2_bridge_intro"] = "sp_bridge_intro"
MapBspConversion["sp_a2_bridge_the_gap"] = "sp_bridge_the_gap"
MapBspConversion["sp_a2_turret_intro"] = "sp_turret_training_advanced"
MapBspConversion["sp_a2_turret_blocker"] = "sp_turret_blocker_intro"
MapBspConversion["sp_a2_column_blocker"] = "sp_column_blocker"
MapBspConversion["sp_a2_laser_vs_turret"] = "sp_laser_vs_turret_intro"
MapBspConversion["sp_a2_laser_relays"] = "sp_laser_relays"
MapBspConversion["sp_a2_ring_around_turrets"] = "sp_ring_around_the_turrets"
MapBspConversion["sp_a2_sphere_peek"] = "sp_catapult_fling_sphere_peek"
MapBspConversion["sp_a2_turret_tower"] = "sp_turret_tower"
MapBspConversion["sp_a4_stop_the_box"] = "sp_stop_the_box"
MapBspConversion["sp_a2_bts1"] = "sp_sabotage_jailbreak"
MapBspConversion["sp_a2_bts3"] = "sp_sabotage_darkness"
MapBspConversion["sp_a2_bts4"] = "sp_sabotage_factory"
MapBspConversion["sp_a2_bts6"] = "sp_sabotage_tube_ride"
MapBspConversion["sp_a2_bts2"] = "sp_sabotage_jailbreak2"
MapBspConversion["sp_a1_intro3"] = "sp_intro_03"
