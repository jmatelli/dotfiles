



# Inventory Checking

Inventory checking is the process of verifying the quantity and condition of items in stock.

Inventory checking should only be done on project inventory and tour inventory, because inventory checking is already done when closing an event for the stands inventory and event inventory.


## Tasks

-  Tour inventory: => **1d**
    -  Create a tour inventory when creating a project (check how the project inventory is done) => **0.5d**
        -  add new column `tourInventoryID` on project (migration file)
        -  add inventory type with value `tour`
        -  in project service CreateProject method => create tour inventory at the same time we create project inventory
    -  add tour inventory under project inventory in "État des stocks" part => **0.25d**
    -  every event that are NOT of commission type `agentFee` should not display `Voir le stock` button BUT should still display stands inventory buttons => **0.25d**

-  agentFee events: => **2.75d**
    -  Remove Stands and Sellers part from the UX if event commission type is `agentFee` => **0.25d**
    -  Make sure that we can start an event of commission type `agentFee` without the need of creating a stand and transfering inventory to this stand => **1d**
    -  Make sure that events that are not of commision type `agentFee` do not create an event inventory => **0.5d**
    -  See if there is any side effects of those modification => **1d**

-  Inventory checking: => **3.25d**
    -  add `check inventory` button on project inventory and tour inventory => **0.25d**
    -  create new page for check inventory (it should look like closing funnel stand inventory) => **1d**
    -  when inventory checking is done create new transfer from inventory to same inventory (create new types on `inventory_level_change` table, `tourInventoryCheck` and `projectInventoryCheck`) => **2d**

-  Transfer changes: (optional) => **2.25d**
    -  add icons on each line of transfers => **0.25d**
    -  add pagination => **1d**
    -  add filters on backend and possibility to filter by `inventory_level_change` type => **1d**

total time without optional => **7d**
total time with optional => **9.25d**
