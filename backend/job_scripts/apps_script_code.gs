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

// to be run only once to store the secret token, delete everything below after running this function in apps script
function setWebhookToken() {
  const token = 'your-random-secret-here';  // must match SHEETS_WEBHOOK_TOKEN in EC2 .env
  PropertiesService.getScriptProperties().setProperty('WEBHOOK_TOKEN', token);
  console.log('Token saved. Delete this function after running.');
}