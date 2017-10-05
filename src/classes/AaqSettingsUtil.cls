public class AaqSettingsUtil {

    private static List<String> searchableRecordTypeIds;
    private static final String AAQObject = 'Solution';

    public static List<String> getValidTypeIds() {
        
        // If we've yet to parse the custom settings for the valid solutions types, then do so & cache
        if ( searchableRecordTypeIds == null ) {
            
            List<String> searchableRecordTypes = getSearchSolTypeNames();
            searchableRecordTypeIds = getRecordTypeIds( AAQObject, searchableRecordTypes );
        
        }
        
        return searchableRecordTypeIds;
        
    }

    private static List<String> getSearchSolTypeNames() {
        
        List<String> searchableList = new List<String>();
        
        // for each searchable RecordType referenced in the Custom Settings...
        for ( SearchedSolutions__c solSearchCustom : SearchedSolutions__c.getall().values() )
            searchableList.add( solSearchCustom.recordTypeName__c );    // ...store it's name in a set of searchable types
        
        return searchableList;
    
    }
    
    private static List<String> getRecordTypeIds( String theObject, List<String> typeNames ) {
        
        List<RecordType> tempRecordList;
        
        if ( typeNames.size() > 0 ) {
            
            tempRecordList = [ Select r.Name, r.Id From RecordType r Where SobjectType=:theObject AND r.Name IN :typeNames ];
            
        } else {    // if no solution record type names have been specified, then we want them all
            
            tempRecordList = [ Select r.Name, r.Id From RecordType r Where SobjectType=:theObject ];
            
        }
        
        
        List<String> theIds = new List<String>();
        
        for ( RecordType recTypeRow : tempRecordList )
            theIds.add( recTypeRow.Id );
            
        return theIds;
        
    }
    

}