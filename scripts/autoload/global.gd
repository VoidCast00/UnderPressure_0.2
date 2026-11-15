extends Node

signal loadDepthUI;  #shop transport -> pick depth -> then loadWaterEnviroment
signal loadWaterEnviroment;
signal loadShopEnviroment;
signal exitGame;

#money you get for selling one of each material
const SELL_PRICES := {
	"rock": 1,
	"iron": 4,
	"gold": 10,
	"amethyst": 12,
	"ruby": 22,
	"osmium": 40,
}

const DAYS_PER_QUOTA := 3

var quota:int = 190;
var day:int =  0; #for the start to start counting
var deadline:int = DAYS_PER_QUOTA;
var quotaCompletedAmount:int = 0;
var depthLevel := 0

var tutorialDone := false

#set by the game manager in game.tscn
var shop_ui: Control
var loading_text: LoadingScreen
var quota_ui: Control


#=== quota =====================================================================

func quota_left() -> int:
	return maxi(quota - quotaCompletedAmount, 0)


func is_quota_met() -> bool:
	return quotaCompletedAmount >= quota


#pays up to amount, never more than you have or more than whats left
func pay_quota(amount: int) -> void:
	var paid := mini(mini(amount, Inventory.cash), quota_left())
	if paid <= 0:
		return
	Inventory.cash -= paid
	quotaCompletedAmount += paid


#quota paid -> double it and give a fresh deadline
func start_next_quota() -> void:
	quota *= 2
	deadline = day + DAYS_PER_QUOTA
	quotaCompletedAmount = 0
