pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import "remix_accounts.sol";
import "../pintu_assessment.sol";

contract PintuAssessmentTest {
    fallback() external payable {}
    
    PintuAssessment pintuAssessmentObj;
    function beforeAll() public {
        pintuAssessmentObj = new PintuAssessment();
    }
    
    function initialBalancesIs0() public {
        Assert.equal(pintuAssessmentObj.balanceOf(TestsAccounts.getAccount(0)), 0, "Initial balance must be 0!");
    }
    
    function initialCounterIs0() public {
        Assert.equal(pintuAssessmentObj.getCounter(), 0, "Initial counter must be 0!");
    }
    
    function incrementCounter() public {
        pintuAssessmentObj.incrementCounter();
        Assert.equal(pintuAssessmentObj.getCounter(), 1, "Value counter must be 1 after 1x increment!");
    }
    
    /* --- Use case (Deposit = 2 Ether) --- */
    /// #value: 2000000000000000000
    function deposit() public payable {
        Assert.equal(msg.value, 2 ether, "Value must be 2 ether!");
        address(pintuAssessmentObj).call.value(msg.value)("");
        Assert.equal(pintuAssessmentObj.balanceOf(address(this)), 2 ether, "Value must be 2 ether after deposited 2 ether!");
    }
    
    /* --- Test case (Withdrawal = 1 ether) with counter = 1 --- */
    /// #value: 1000000000000000000
    function withdrawWithCounterLessThan10() public payable {
        Assert.equal(msg.value, 1 ether, "Value must be 1 ether!");
        Assert.equal(pintuAssessmentObj.balanceOf(address(this)), 2 ether, "Value must be 2 ether after deposited 2 ether!");
        Assert.ok(pintuAssessmentObj.getCounter() < 10, "Counter must be < 10");
        
        try pintuAssessmentObj.withdraw{gas: 40000}(msg.value) {
            Assert.ok(false, "Withdrawal should be failed");
        } catch Error (string memory _err) {
            Assert.ok(true, 'Correct behaviour');
        } catch (bytes memory) {
            /*  For low level data runtime error */
            Assert.ok(true, 'Correct behaviour');
        }
    }
    
    function incrementCounter9Times() public {
        Assert.equal(pintuAssessmentObj.getCounter(), 1, "Value counter must be 1 after 1x increment!");
        for(uint i=0;i<9;i++) {
            pintuAssessmentObj.incrementCounter();    
        }
        
        Assert.equal(pintuAssessmentObj.getCounter(), 10, "Value counter must be 19 after 9x increment!");
    }
    
    /* --- Test case (Withdrawal = 1 ether) with counter = 10 --- */
    /// #value: 1000000000000000000
    function withdrawWithCounterGreaterThan10() public payable {
        Assert.equal(msg.value, 1 ether, "Value must be 1 ether!");
        Assert.equal(pintuAssessmentObj.balanceOf(address(this)), 2 ether, "Value must be 2 ether after deposited 2 ether!");
        Assert.equal(pintuAssessmentObj.getCounter(),  10, "Counter must be 10");
        
        try pintuAssessmentObj.withdraw{gas: 1000000000}(msg.value) {
            Assert.ok(true, "Withdrawal success");
        } catch Error (string memory _err) {
            Assert.ok(false, _err);
        } catch (bytes memory _err) {
            /*  For low level data runtime error */
            Assert.ok(false, string(_err));
        }
        
        Assert.equal(pintuAssessmentObj.balanceOf(address(this)), 1 ether, "Value must be 1 ether after withdrawn 1 ether");
    }
}
