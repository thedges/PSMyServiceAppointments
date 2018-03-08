public class PSMyServiceAppointmentsController {
    @AuraEnabled
    public static String getAppointments(String view)
    {
        String userId = UserInfo.getUserId();
        //userId = '0056A000001hfD5QAI';   // override for testing
        
        List<Appointment> apptList = new List<Appointment>();
        
        String queryStr = 'SELECT Id, ServiceAppointment.Status, ServiceAppointment.AppointmentNumber, ServiceAppointment.Id, ServiceAppointment.Subject,\n' +
            '       ServiceAppointment.SchedStartTime, ServiceAppointment.ParentRecordId\n' +
            '  FROM AssignedResource\n' +
            ' WHERE ServiceAppointment.ParentRecordType = \'WorkOrder\' AND ServiceResource.RelatedRecord.Id = \'' + userId + '\'' + 
            ' AND ';
        
        Date dt = Date.today();
        
        if (view == 'Today')
        {
           DateTime startDttm = DateTime.newInstance(dt, Time.newInstance(0,0,0,0));
           DateTime stopDttm = DateTime.newInstance(dt.addDays(1), Time.newInstance(0,0,0,0));
           queryStr += 'ServiceAppointment.SchedStartTime >= ' + startDttm.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') +  
                       ' AND ServiceAppointment.SchedStartTime < ' + stopDttm.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        else
        {
           DateTime startDttm = DateTime.newInstance(dt, Time.newInstance(0,0,0,0));
           DateTime stopDttm = DateTime.newInstance(dt.addDays(31), Time.newInstance(0,0,0,0));
           queryStr += 'ServiceAppointment.SchedStartTime >= ' + startDttm.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + 
                       ' AND ServiceAppointment.SchedStartTime <= ' + stopDttm.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');

        }
        
        queryStr += '\n ORDER BY ServiceAppointment.SchedStartTime';
        
        System.debug(queryStr);
        
        List<AssignedResource> saList = Database.query(queryStr);
        
        if (saList != null && saList.size() > 0)
        {
            List<ID> woIdList = new List<ID>();
            for (AssignedResource ar : saList)
            {
                woIdList.add(ar.ServiceAppointment.ParentRecordId);
            }
            
            //Map<ID, Account> m = new Map<ID, Account>([SELECT Id, Name FROM Account LIMIT 10]);
            Map<ID, WorkOrder> woMap = new Map<ID, WorkOrder>([SELECT Id, WorkOrderNumber, Account.Id, Account.Name, Contact.Id, Contact.Name, Street, City, State, PostalCode, WorkType.Name
                                        FROM WorkOrder 
                                       WHERE ID IN :woIdList]);
            
            for (AssignedResource ar : saList)
            {
                Appointment appt = new Appointment();
                appt.raId = ar.Id;
                appt.status = ar.ServiceAppointment.Status;
                appt.saNum = ar.ServiceAppointment.AppointmentNumber;
                appt.saLink = '/' + ar.ServiceAppointment.Id;
                appt.woNum = woMap.get(ar.ServiceAppointment.ParentRecordId).WorkOrderNumber;
                appt.woLink = '/' + woMap.get(ar.ServiceAppointment.ParentRecordId).Id;
                
                if (woMap.get(ar.ServiceAppointment.ParentRecordId).Account.Id != null)
                {
                  appt.accountName = woMap.get(ar.ServiceAppointment.ParentRecordId).Account.Name;
                  appt.accountLink = '/' + woMap.get(ar.ServiceAppointment.ParentRecordId).Account.Id;
                }
                
                if (woMap.get(ar.ServiceAppointment.ParentRecordId).Contact.Id != null)
                {
                  appt.contactName = woMap.get(ar.ServiceAppointment.ParentRecordId).Contact.Name;
                  appt.contactLink = '/' + woMap.get(ar.ServiceAppointment.ParentRecordId).Contact.Id;
                }
                
                if (woMap.get(ar.ServiceAppointment.ParentRecordId).street != null)
                {
                  appt.address = woMap.get(ar.ServiceAppointment.ParentRecordId).street + '\n' +
                                woMap.get(ar.ServiceAppointment.ParentRecordId).city + ', ' + woMap.get(ar.ServiceAppointment.ParentRecordId).state + ' ' + 
                                woMap.get(ar.ServiceAppointment.ParentRecordId).postalCode;
                }
                
                appt.schedStartTime = ar.ServiceAppointment.SchedStartTime.format();
                appt.workType = woMap.get(ar.ServiceAppointment.ParentRecordId).WorkType.Name;
                
                
                apptList.add(appt);
            }
            
        }
        
        
        return JSON.serialize(apptList);
    }
    
    public class Appointment
    {
        public String raId;
        public String saId;
        public String status;
        public String saNum;
        public String saLink;
        public String woId;
        public String woNum;
        public String woLink;
        public String accountId;
        public String accountName;
        public String accountLink;
        public String contactId;
        public String contactName;
        public String contactLink;
        public String address;
        public String schedStartTime;
        public String workType;
    }
}