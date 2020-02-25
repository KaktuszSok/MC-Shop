# MC-Shop
Shop system for Minecraft using ComputerCraft.

Making this work in Minecraft proved to be harder than it seems, as well as having no experience with lua or Computercraft before.

Images: https://imgur.com/a/OW6ZoMJ

Features:
-Easily configurable
-Simple to use
-Can sell any item or combination of items
-Can use any item as currency
-Secure (shop cannot be stolen from as all processing is handled in a remote base)
-Customer will not be charged if goods are out of stock
-Shop will be kept stocked automatically if connected to a larger storage network which it will use as a source

How it works:
There are two computers, the main one running shop.lua and the second one running stock.lua

shop.lua:
-When a signal is received, it:
-Loads the trade terms from a configuration chest (i.e. what is being sold and for how much)
-Verifies good being sold is in stock
-Verifies that payment present in the transaction chest is sufficient
-Transfers appropriate amount of currency from transaction chest to the currency output chest, ready to be collected by shop owner
-Transfers appropriate goods from the supply chest to the transaction chest, ready for the customer to take
-Logs transaction and whether it was successful or not, and, if not, states the reason (e.g. out of stock, insufficient payment, etc.)

stock.lua:
-Uses configuration chest as a template to keep the supply chest stocked with the appropriate items
-Pulls from a "source" chest, into which the items to be sold should be pumped into
-Inserts correct items from source chest into the appropriate slots in the supply chest, so that shop.lua can easily sell them to the player
-Vitally, it makes sure that space is reserved for each item type being sold. This way, in the event of multiple items being sold, the source chest does not clog up with only one of those items. This is the main reason this program is necessary.
