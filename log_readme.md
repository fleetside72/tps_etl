the journal module is fine forvbasic items, but when entering recipts, a single item has two entries but they are hard to match up. this could be solved by creating a separate schema module that has a head, item, the glbsub items for each main item.

is there a way to do this such that subsequent usage can identify any component of the json with one access path?

or should each push to evt.log pre-implement the down-stream transformation to avoid this?

So the main json structure woudl have a header-item, but then there woudl also be a GL array of items that are assoiated with teh othe header-item lines but not under them as heirarchy items
The gl key then woudl be a header-item combination and coudl have a debit credit off of each of those

based on inital experience with manually loading receipts, may be good to setup a receipt module that automatically sets up the offset and reverses the sign, maybe a preview of the json
