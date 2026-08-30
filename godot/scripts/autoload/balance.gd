extends Node
## Port of src/game/balance.zig (BETA 0.6.0-alpha)

const STARTING_TREASURY: int = 3000
const JOB_RADIUS: float = 5.5

const EVENT_INTERVAL: float = 22.0
const RIVAL_INTERVAL: float = 16.0
const STREET_EVENT_INTERVAL: float = 45.0
const AMBUSH_CHECK_INTERVAL: float = 35.0

const BOOTLEG_DURATION: float = 3.0
const PROTECTION_DURATION: float = 2.5
const SMUGGLING_DURATION: float = 4.0

const HEAT_JOB_MULT: int = 2
const WANTED_RISK_THRESHOLD: int = 6

const HEAL_PER_SEC: float = 2.0
const HEAL_MAX_HEAT: int = 25

const TOAST_JOB_SEC: float = 3.0
const TOAST_SAVE_SEC: float = 2.0

const TIME_SCALE_DEMO: float = 18.0

const BRIBE_COST: int = 500
const FENCE_HEAT_COST: int = 200
const STASH_CHUNK: int = 250
const LOAN_MAX: int = 1500
const RACKET_UPGRADE_COST: int = 800
const COLLECT_BASE: int = 350
const RECRUIT_COST: int = 600
const SAFEHOUSE_CD: float = 30.0
