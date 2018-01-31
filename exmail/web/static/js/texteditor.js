// Simple editor
'use strict';

$(function() {

if ($('#texteditor').length <= 0) {
  return;
}

const saveDocument = () => {
  const form = $('#texteditor');
  let data = {body: $('#texteditor-textarea').val()};

  form.serializeArray().map((x) => data[x.name] = x.value)

  $.ajax({
    url: form.attr('action'),
    type: "POST",
    data: data,
    success: msg => {},
  });
};

const globalConfig = $('#texteditor-config').data();
$.get(globalConfig.tpl, (tpl) => {



const $doc = $('#texteditor-textarea').val(globalConfig.tpl ? tpl : globalConfig.defaultTpl);
let editable = true;

// Set template when user edits template.
$doc.on("keyup click", () => {
  if (editable) {
    editable = false

    setTimeout(() => {
      editable = true;

      saveDocument();

    }, 2000);
  }
});

// Auto save per thirty seconds.
setInterval(() => {
  editable = false; saveDocument(); editable = true;
}, 30000);

// Auto save document when user transfers to another page.
(() => {
  let sent = false
  $(window).one('beforeunload pagehide unload', function() {
    if (! sent) {
      sent = true; saveDocument();
    }
  });
})();




});
});
