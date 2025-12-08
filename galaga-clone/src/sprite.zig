pub const SpriteType = enum {
    player,
    boss,
    goei,
    zako,
    scorpion,
    midori,
    galaxian,
    tombow,
    momji,
    enterprise,
};

pub const SpriteFrame = struct { col: u16, row: u16, width: u16, height: u16, angle_deg };

pub const Sprite = struct {
    type: SpriteType,
    idle_frames: []SpriteFrame,
};
