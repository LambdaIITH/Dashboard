// Code.gs
const WEBHOOK_URL = 'https://api.iith.dev/mess_menu/webhook/sheets';
const WATCHED_SHEETS = ['Weekly_Menu', 'Daily_Base', 'Extras_Menu', 'Special_Dinner'];

// NOTE: Named `onSheetEdit` instead of `onEdit` because simple triggers (functions named `onEdit`)
// are forbidden from making outbound network requests via UrlFetchApp in Google Apps Script.
// This function MUST be invoked via an installable trigger (configured via setWebhookToken).
function onSheetEdit(e) {
  if (!e || !e.range) return;
  const sheet = e.range.getSheet();
  if (!WATCHED_SHEETS.includes(sheet.getName())) return;

  const lock = LockService.getScriptLock();
  if (!lock.tryLock(5000)) return;
  
  try {
    Utilities.sleep(2000);
    
    const props = PropertiesService.getScriptProperties();
    const token = props.getProperty('WEBHOOK_TOKEN');
    
    const headers = {};
    if (token) {
      headers['X-Webhook-Token'] = token;
    }
    
    const response = UrlFetchApp.fetch(WEBHOOK_URL, {
      method: 'post',
      contentType: 'application/json',
      headers: headers,
      payload: JSON.stringify({ sheet: sheet.getName(), timestamp: new Date().toISOString() }),
      muteHttpExceptions: true
    });

    // muteHttpExceptions suppresses HTTP errors, so check the status ourselves.
    // Throwing marks the execution as failed in the Executions log and triggers
    // Apps Script's failure notification emails.
    const code = response.getResponseCode();
    if (code < 200 || code >= 300) {
      const msg = 'Webhook failed for sheet "' + sheet.getName() + '": HTTP ' + code + ' ' +
        response.getContentText().substring(0, 500);
      console.error(msg);
      throw new Error(msg);
    }
  } finally {
    lock.releaseLock();
  }
}

// Run this ONCE to set token AND create installable trigger
function setWebhookToken() {
  const token = 'your-random-secret-here';  // CHANGE THIS to match EC2 SHEETS_WEBHOOK_TOKEN
  PropertiesService.getScriptProperties().setProperty('WEBHOOK_TOKEN', token);
  
  // Delete existing triggers for this project to prevent duplicates
  ScriptApp.getProjectTriggers().forEach(t => {
    if (t.getHandlerFunction() === 'onSheetEdit' || t.getHandlerFunction() === 'onEdit') {
      ScriptApp.deleteTrigger(t);
    }
  });
  
  // Create installable onEdit trigger pointing to onSheetEdit
  ScriptApp.newTrigger('onSheetEdit')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onEdit()
    .create();
  
  console.log('Token saved & installable trigger created. Check Triggers tab to verify.');
}
