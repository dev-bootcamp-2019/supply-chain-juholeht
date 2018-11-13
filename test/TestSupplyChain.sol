pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;

  function ThrowProxy(address _target) {
    target = _target;
  }

  //prime the data using the fallback function.
  function() {
    data = msg.data;
  }

  function execute() returns (bool) {
    return target.call(data);
  }
}

contract TestSupplyChain {

    uint public initialBalance = 1 ether;


    event AddressEvent(string note, address addr);

    // Test for failing conditions in this contracts
    // test that every modifier is working
    
    // buyItem

    // test for failure if user does not send enough funds
    function testUserDoesNotSendEnoughFunds() {
        SupplyChain supplyChain =  SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("banana", 4 finney);

        ThrowProxy throwProxy = new ThrowProxy(address(supplyChain));
        SupplyChain(address(throwProxy)).buyItem.value(0 finney)(0);

        bool r = throwProxy.execute.gas(200000)();

        Assert.isFalse(r, "Call should not pass. Not enough funds sent.");
    }

    // test for purchasing an item that is not for Sale
    function testItemIsNotForSale() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("kiwi", 4 finney);
        supplyChain.buyItem.value(5 finney)(1);
        bool passed = address(supplyChain).call(bytes4(keccak256("buyItem(uint)")), 1);
        
        Assert.isFalse(passed, "Call should not pass. Item not for Sale");
    }
/*
    // TODO:
    // shipItem

    // test for calls that are made by not the seller
    function testShipItemIsCalledByNotSeller() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("melon", 4 finney);
        supplyChain.buyItem.value(5 finney)(2);
        
        // Using different address through proxy
        ThrowProxy throwProxy = new ThrowProxy(address(supplyChain));
        SupplyChain(address(throwProxy)).shipItem(2);

        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Call should not pass. Not enough funds sent.");
    }

    // test for trying to ship an item that is not marked Sold
    function testTryToShipItemThatIsNotSold() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("orange", 4 finney);
        bool passed = address(supplyChain).call(bytes4(keccak256("shipItem(uint)")), 3);
        
        Assert.isFalse(passed, "Call should not pass. Item not yet Sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    function testCallReveiceItemFromTheAddressThatIsNotBuyer() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("mango", 4 finney);
        supplyChain.buyItem.value(5 finney)(4);
        supplyChain.shipItem(4);
        
        ThrowProxy throwProxy = new ThrowProxy(address(supplyChain));
        SupplyChain(address(throwProxy)).receiveItem(4);

        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Call should not pass. Reveiver != buyer address");
    }



    // test calling the function on an item not marked Shipped
    function testTryToReveiceItemIfItemIsNotShipped() {
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem("grape", 4 finney);


    }*/
}
