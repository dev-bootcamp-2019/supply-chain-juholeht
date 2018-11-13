pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";


contract ExternalPerson {

    address public target;

    function ExternalPerson(address supplyChainAddress) public {
        target = supplyChainAddress;
    }

    function () public payable {}

    function testBuyItem(uint offer, uint ska) public returns (bool) {
        return address(target).call.value(offer)(bytes4(keccak256("buyItem(uint256)")), ska);
    }

    function testShipItem(uint ska) public returns (bool) {
        return address(target).call(bytes4(keccak256("shipItem(uint256)")), ska);
    }

    function testReceiveItem(uint ska) public returns (bool) {
        return address(target).call(bytes4(keccak256("receiveItem(uint256)")), ska);
    }
}


contract TestSupplyChain {

    uint public initialBalance = 2 ether;

    function () public payable {}

    // Test for failing conditions in this contracts
    // test that every modifier is working
    
    // buyItem

    // test for failure if user does not send enough funds
    function testUserDoesNotSendEnoughFunds() {
        SupplyChain supplyChain =  SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("banana", 4 finney);

        ExternalPerson extPerson = new ExternalPerson(supplyChain);
        address(extPerson).transfer(10 finney);
        
        bool passed = extPerson.testBuyItem(2 finney, 0);

        Assert.isFalse(passed, "Call should not pass. Not enough funds sent.");
    }

    // test for purchasing an item that is not for Sale
    function testItemIsNotForSale() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("kiwi", 4 finney);
        supplyChain.buyItem.value(5 finney)(1);
        
        bool passed = address(supplyChain).call.value(5 finney)(bytes4(keccak256("buyItem(uint256)")), 1);

        Assert.isFalse(passed, "Call should not pass. Item not for Sale");
    }

    // shipItem

    // test for calls that are made by not the seller
    function testShipItemIsCalledByNotSeller() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("melon", 4 finney);

        ExternalPerson extPerson = new ExternalPerson(supplyChain);
        address(extPerson).transfer(10 finney);
        extPerson.testBuyItem(5 finney, 2);
        
        bool passed = extPerson.testShipItem(2);

        Assert.isFalse(passed, "Call should not pass. Only item seller can ship item.");
    }

    // test for trying to ship an item that is not marked Sold
    function testTryToShipItemThatIsNotSold() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("orange", 4 finney);
        
        bool passed = address(supplyChain).call(bytes4(keccak256("shipItem(uint256)")), 3);
        
        Assert.isFalse(passed, "Call should not pass. Item is not yet Sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    function testCallReveiceItemFromTheAddressThatIsNotBuyer() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("mango", 4 finney);
        supplyChain.buyItem.value(5 finney)(4);
        supplyChain.shipItem(4);
        
        ExternalPerson extPerson = new ExternalPerson(supplyChain);
        address(extPerson).transfer(10 finney);
        
        bool passed = extPerson.testReceiveItem(4);
        
        Assert.isFalse(passed, "Call should not pass. Reveiver != buyer address");
    }

    // test calling the function on an item not marked Shipped
    function testTryToReveiceItemIfItemIsNotShipped() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("grape", 4 finney);
        supplyChain.buyItem.value(5 finney)(5);

        bool passed = address(supplyChain).call(bytes4(keccak256("receiveItem(uint256)")), 5);

        Assert.isFalse(passed, "Call should not pass. Item is not yet Shipped");
    }
}
