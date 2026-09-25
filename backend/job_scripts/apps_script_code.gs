// Code.gs
const WEBHOOK_URL = 'https://api.iith.dev/mess_menu/webhook/sheets';
const WATCHED_SHEETS = ['Weekly_Menu', 'Daily_Base', 'Extras_Menu', 'Special_Dinner'];

function onEdit(e) {
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
    
    UrlFetchApp.fetch(WEBHOOK_URL, {
      method: 'post',
      contentType: 'application/json',
      headers: headers,
      payload: JSON.stringify({ sheet: sheet.getName(), timestamp: new Date().toISOString() }),
      muteHttpExceptions: true
    });
  } finally {
    lock.releaseLock();
  }
}

// Run this ONCE to set token AND create installable trigger
function setWebhookToken() {
  const token = 'your-random-secret-here';  // CHANGE THIS to match EC2 SHEETS_WEBHOOK_TOKEN
  PropertiesService.getScriptProperties().setProperty('WEBHOOK_TOKEN', token);
  
  // Delete existing onEdit triggers for this project
  ScriptApp.getProjectTriggers().forEach(t => {
    if (t.getHandlerFunction() === 'onEdit') {
      ScriptApp.deleteTrigger(t);
    }
  });
  
  // Create installable onEdit trigger
  ScriptApp.newTrigger('onEdit')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onEdit()
    .create();
  
  console.log('Token saved & installable trigger created. Check Triggers tab to verify.');
}