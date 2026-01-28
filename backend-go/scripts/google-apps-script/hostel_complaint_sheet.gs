//Admin Key
const API_KEY = 'SUPER_STRONG_PASSWORD';
const BACKEND_URL = 'http://url-to-backend.com/'
const ADMIN_KEY = 'VerySecretKey'

function doPost(e) {
  var lock = LockService.getScriptLock();
  if (!lock.tryLock(10000)) { //10 seconds await
    return ContentService.createTextOutput(JSON.stringify({ 'result': 'error', 'error': 'Server is busy, please try again later.' }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  try {
    //Authentication
    //Expects URL like: https://script.google.com/.../exec?auth=SUPER_STRONG_PASSWORD
    if (!e.parameter.auth || e.parameter.auth !== API_KEY) {
      return ContentService.createTextOutput(JSON.stringify({ 'result': 'error', 'error': 'Unauthorized' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Complaints');
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({ 'result': 'error', 'error' : "Sheet 'Complaints' not found" }))
      .setMimeType(ContentService.MimeType.JSON);
    }

    var data = JSON.parse(e.postData.contents);
    
    // 1. Complaint ID
    var id = data.id;

    // 2. Name
    var name = data.user_name || 'N/A';

    // 3. Phone Number
    var phone = data.user_phone || '';

    // 4. Roll Number
    var rollNo = data.user_roll_no || '';

    // 5. Room Number
    var roomNo = data.room_number || '';

    // 6. Hostel
    var hostel = data.hostel_name || '';

    // 7. Created At
    var createdAt = data.created_at || '';

    // 8. Status (Pending, On Going, Resolved)
    var status = data.complaint_status || 'Pending';
    
    // 9. complaint_type
    var type = data.complaint_type || 'Unknown';

    // 10. complaint_subcategory
    var subCatVal = data.complaint_subcategory || '';

    // 11. issue_type
    var issueVal = data.issue_type || '';

    // 12. user comments
    var description = data.complaint_description || '';

    // 13-17. Images (Up to 5)
    var images = data.images || [];
    var img1 = images.length > 0 ? images[0] : '';
    var img2 = images.length > 1 ? images[1] : '';
    var img3 = images.length > 2 ? images[2] : '';
    var img4 = images.length > 3 ? images[3] : '';
    var img5 = images.length > 4 ? images[4] : '';

    // Append Row
    // Header: Complaint ID, Name, Phone Number, Roll Number, Room Number, Hostel, Created At, Status, complaint_type, complaint_subcategory, issue_type, user comments, image-1, image-2, image-3, image-4, image-5
    sheet.appendRow([
      id,
      name,
      phone,
      rollNo,
      roomNo,
      hostel,
      createdAt,
      status,
      type,
      subCatVal,
      issueVal,
      description,
      img1,
      img2,
      img3,
      img4,
      img5
    ]);

    return ContentService.createTextOutput(JSON.stringify({ 'result': 'success', 'row': sheet.getLastRow() }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (e) {
    return ContentService.createTextOutput(JSON.stringify({ 'result': 'error', 'error': e.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
    
  } finally {
    lock.releaseLock();
  }
}


// to update status to show the user
function onEditTrigger(e) {
  var sheet = e.source.getActiveSheet();
  if (sheet.getName() !== "Complaints") return;

  var range = e.range;
  var col = range.getColumn();
  var row = range.getRow();
  
  if (row <= 1) return; // Header

  // Column 8 is Status
  if (col === 8) {
    var newStatus = e.value;
    var idCell = sheet.getRange(row, 1); // ID is Column 1
    var id = idCell.getValue();

    if (!id) return; // No ID, ignore

    // Handle "Resolved" Logic locally
    if (newStatus === "Resolved") {
      var resolvedAtCell = sheet.getRange(row, 18); // Column 18 is Resolved At
      var now = new Date();
      resolvedAtCell.setValue(now.toISOString());
    }

    // Call Backend
    syncToBackend(id, newStatus);
  }
}

function syncToBackend(id, status) {
  var url = BACKEND_URL + "hostel-complaints/" + id + "/status";
  
  var payload = {
    "new_status": status
  };
  
  var options = {
    'method': 'patch',
    'contentType': 'application/json',
    'headers': {
      'X-Admin-Key': ADMIN_KEY
    },
    'payload': JSON.stringify(payload),
    'muteHttpExceptions': true
  };
  
  try {
    var response = UrlFetchApp.fetch(url, options);
    Logger.log("Sync Response: " + response.getContentText());
  } catch (err) {
    Logger.log("Sync Error: " + err.toString());
    Browser.msgBox("Error syncing to backend: " + err.toString());
  }
}


