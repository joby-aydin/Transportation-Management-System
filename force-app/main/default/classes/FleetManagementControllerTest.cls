@isTest
public class FleetManagementControllerTest {
    @isTest
    static void testGetBusList() {
        List<Bus__c> busList = new List<Bus__c>();
        for (Integer i = 1; i <= 5; i++) {
            Bus__c bus = new Bus__c(Name = 'Bus ' + i);
            busList.add(bus);
        }
        insert busList;

        Test.startTest();
        List<Bus__c> result = FleetManagementController.getBusList();
        Integer expectedSize = 5;
        Test.stopTest();

        System.assertEquals(expectedSize, result.size());
    }

    @isTest 
    static void testUpdateBus() {
        // Create a test bus
        Bus__c testBus = new Bus__c(
            Name = 'Test Bus',
            Odometer_Reading__c = 50000
        );
        insert testBus;

        // Prepare the updated data
        Map<String, Object> busData = new Map<String, Object> {
            'Name' => 'Updated Bus',
            'Odometer_Reading__c' => '55000'
        };

        // Call the updateBus method
        Test.startTest();
        FleetManagementController.updateBus(testBus.Id, busData);
        Test.stopTest();

        // Query the updated bus
        Bus__c updatedBus = [SELECT Id, Name, Year__c, Maximum_Capacity__c, Odometer_Reading__c FROM Bus__c WHERE Id = :testBus.Id];

        // Assert that the bus was correctly updated
        System.assertEquals('Updated Bus', updatedBus.Name);
        System.assertEquals(55000, updatedBus.Odometer_Reading__c);
    }
    
    @isTest
    static void testGetResaleValue24() {
        Bus__c bus = new Bus__c(Name = 'Bus', Year__c = 2000, Maximum_Capacity__c = 24,
                               Odometer_Reading__c = 110000, Air_Conditioning__c = false,
                               Current_Status__c = 'Ready for Use');
        insert bus;

        Test.startTest();
        Decimal expectedResaleValue = (120000- ((110000 - 100000) * 0.10));
        Decimal result = FleetManagementController.getResaleValue(bus.Id);
        Test.stopTest();

        System.assertEquals(expectedResaleValue, result);
    }
    
    @isTest
    static void testGetResaleValue36() {
        
        Bus__c bus = new Bus__c(Name = 'Bus', Year__c = 2022, Maximum_Capacity__c = 36,
                               Odometer_Reading__c = 110000, Air_Conditioning__c = true,
                               Current_Status__c = 'Ready for Use');
        insert bus;

        Test.startTest();
        Decimal expectedResaleValue = (160000-((110000-100000)*0.1)) + (160000*0.03) ;
        Decimal result = FleetManagementController.getResaleValue(bus.Id);
        Test.stopTest();

        System.assertEquals(expectedResaleValue, result);
    }
    
    @isTest
    static void testGetResaleValueNull() {
        
        Bus__c bus2 = new Bus__c(Name = 'Bus', Year__c = 2022, Maximum_Capacity__c = 24,
                               Odometer_Reading__c = 110000, Air_Conditioning__c = true,
                               Current_Status__c = 'Undergoing Repairs');
        insert bus2;

        Test.startTest();
        Decimal expectedResaleValue2 = null;
        Decimal result2 = FleetManagementController.getResaleValue(bus2.Id);
        Test.stopTest();

        System.assertEquals(expectedResaleValue2, null);
    }
    
    @isTest
    static void testGetResaleValueYear() {
        
        Bus__c bus = new Bus__c(Name = 'Bus', Year__c = 1972, Maximum_Capacity__c = 36,
                               Odometer_Reading__c = 110000, Air_Conditioning__c = true,
                               Current_Status__c = 'Ready for Use');
        insert bus;

        Test.startTest();
        Decimal expectedResaleValue = (160000-((110000-100000)*0.1)) + (160000*0.03) + (160000*0.34) ;
        Decimal result = FleetManagementController.getResaleValue(bus.Id);
        Test.stopTest();

        System.assertEquals(expectedResaleValue, result);
    }
    
    @isTest
    static void testGetResaleValueNoCapacity() {
        
        Bus__c bus = new Bus__c(Name = 'Bus', Year__c = 1972, Maximum_Capacity__c = null,
                               Odometer_Reading__c = 110000, Air_Conditioning__c = true,
                               Current_Status__c = 'Ready for Use');
        insert bus;

        Test.startTest();
        Decimal expectedResaleValue = null ;
        Decimal result = FleetManagementController.getResaleValue(bus.Id);
        Test.stopTest();

        System.assertEquals(expectedResaleValue, result);
    }
}