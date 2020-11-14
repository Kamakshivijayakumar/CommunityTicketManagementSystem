@isTest
public class DataManager_UtilsTest {
    
    // ========================= calculateDaysDifference ===================================
    @isTest static void testTodayDaysDifference() {
        Date now = Date.today();
        System.assertEquals(0,DataManager_Utils.calculateDaysDifference(now));
    }
    
    // ========================= string2Date ===================================
    @isTest static void testDateStringValid() {
        Date dateGen = DataManager_Utils.string2Date('2015-07-08');
        System.assertEquals(2015,dateGen.year());
        System.assertEquals(7,dateGen.month());
        System.assertEquals(8,dateGen.day());
    }
    @isTest static void testDateStringInvalid() {
        System.assertEquals(null,DataManager_Utils.string2Date('YYYY-MM-DD'));
    }
    @isTest static void testDateStringTooShort() {
        System.assertEquals(null,DataManager_Utils.string2Date('AA'));
    }
    
    // ========================= isInTimeframe ===================================
    @isTest static void testTimeframe() {
        Date now = Date.today();
        Date tooLate = now.addMonths(-13);
        Opportunity o = new Opportunity(CloseDate= tooLate);
        System.assertEquals(false, DataManager_Utils.isInTimeframe(o, 12));
    }
}