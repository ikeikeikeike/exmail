// Simple editor
'use strict';

$(function() {



if ($('#tinyeditor').length <= 0) {
  return;
}

const globalConfig = $('#tinyeditor-config').data();
$.get(globalConfig.tpl, (tpl) => {




const screenY =
  window.innerHeight ||
  document.documentElement.clientHeight ||
  document.body.clientHeight;


const unvisualContent = (ed, cb) => {
  const hasVisual = ed.hasVisual;

  ed.hasVisual = false;
  ed.addVisual()

  const docstring = ed.getDoc().children[0].outerHTML;

  ed.hasVisual = hasVisual;
  ed.addVisual()

  const sel  = "[class^='mce-'],#mceDefaultStyles,[href*=tinymce]",
        doc  = (new DOMParser()).parseFromString(docstring, "text/html"),
        head = $('<div/>').append($(doc.head.outerHTML).not(sel)).html();
  let   body = $('<div/>').append($(doc.body.outerHTML).not(sel)).html();

  if (cb) body = cb(body)

  return `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html><head>`+head+`</head><body>`+body+`</body></html>`;
};


const saveDocument = (ed) => {
  const form = $('#tinyeditor');
  let   data = {
    body: unvisualContent(ed, body => body)
  };

  form.serializeArray().map((x) => data[x.name] = x.value)

  $.ajax({
    url: form.attr('action'),
    type: "POST",
    data: data,
    success: msg => {},
  });
};


tinymce.init({
  selector: 'textarea',
  // language: "ja",
  mode: "exact",
  theme: "modern",
  height: screenY - 200,
  autosave_interval: "60s",
  visual: true,
  menubar: true,
  statusbar: true,

  ////// TODO: will check to valid options below
  verify_html: false,
  inline_styles: true,
  valid_elements : 'a[href|target=_blank],strong/b,div[align],br',
  //////

  toolbar1: [
    'save restoredraft | undo redo | insert | styleselect fontselect fontsizeselect ',
  ].join(),

  toolbar2: [
    'forecolor backcolor | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',  // media
  ].join(),

  font_formats: 'Arial=arial,helvetica,sans-serif;Courier New=courier new,courier,monospace;AkrutiKndPadmini=Akpdmi-n',
  fontsize_formats: '6pt 8pt 10pt 12pt 14pt 18pt 24pt 36pt',

  style_formats_merge: true,
  style_formats: [
    {
      title: "Margin", items: [
        {title: "10", selector: 'div', styles: {'margin': '10px'}},
        {title: "20", selector: 'div', styles: {'margin': '20px'}},
        {title: "30", selector: 'div', styles: {'margin': '30px'}},
        {title: "40", selector: 'div', styles: {'margin': '40px'}},
        {title: "50", selector: 'div', styles: {'margin': '50px'}},
        {title: "60", selector: 'div', styles: {'margin': '60px'}},
        {title: "70", selector: 'div', styles: {'margin': '70px'}},
        {title: "80", selector: 'div', styles: {'margin': '80px'}},
        {title: "90", selector: 'div', styles: {'margin': '90px'}},
      ]
    }, {
      title: "Padding", items: [
        {title: "10", selector: 'div', styles: {'padding': '10px'}},
        {title: "20", selector: 'div', styles: {'padding': '20px'}},
        {title: "30", selector: 'div', styles: {'padding': '30px'}},
        {title: "40", selector: 'div', styles: {'padding': '40px'}},
        {title: "50", selector: 'div', styles: {'padding': '50px'}},
        {title: "60", selector: 'div', styles: {'padding': '60px'}},
        {title: "70", selector: 'div', styles: {'padding': '70px'}},
        {title: "80", selector: 'div', styles: {'padding': '80px'}},
        {title: "90", selector: 'div', styles: {'padding': '90px'}},
      ]
    }
  ],

  plugins: [
    'autoresize textcolor fullpage advlist autolink lists link image imagetools charmap',
    'print anchor searchreplace visualblocks code autosave save',  // preview fullscreen
    'insertdatetime media table contextmenu paste code',
  ],

  image_advtab: true,
  relative_urls : false,
  remove_script_host : false,
  // paste_data_images: false,
  file_picker_callback: function(callback, value, meta) {
    if (meta.filetype == 'image') {
      $('#upload-file [type=file][name=image]').trigger('click').on('change', function() {
        const form   = $('#upload-file'),
              file   = this.files[0],
              reader = new FileReader();

        reader.onload = (e) => {
          let data = {image: e.target.result};
          form.serializeArray().map(x => data[x.name] = x.value)

          $.ajax({
            url: form.attr('action'),
            type: "POST",
            data: data,
            success: msg => {
              if (msg.status) {
                callback(msg.url, {alt: ''});
              } else {
                alert("Upload image something wrong")
              }
            },
          });
        };

        reader.readAsDataURL(file);
      });
    }
  },
  // content_css: '//www.tinymce.com/css/codepen.min.css',

  setup: (ed) => {
    let doc, editable = true,
        $preview  = $('#tinyeditor-preview');

    // Set template in init
    ed.on("init", () => {

      ed.setContent(tpl);

      $preview.html(unvisualContent(ed));

      $('#tinyeditor-preview')
        .css('overflow-y', 'scroll')
        .css('height', $("#tinyeditor-textarea_ifr").height());

      $("#tinyeditor iframe").contents().scroll(function() {
        $('#tinyeditor-preview').scrollTop($(this).scrollTop());
      });
    });

    // Set template when user edits template.
    ed.on("keyup click", () => {
      if (editable) {
        editable = false

        setTimeout(() => {
          editable = true;

          $preview.html(unvisualContent(ed));
        }, 2000);
      }
    });

    setInterval(() => {
      editable = false; $preview.html(unvisualContent(ed)); editable = true;
    }, 5000);

    // Auto save document when user transfers to another page.
    (() => {
      let sent = false
      $(window).one('beforeunload pagehide unload', function() {
        if (! sent) {
          sent = true; saveDocument(ed);
        }
      });
    })();

  },

  save_onsavecallback: saveDocument

});





});
});
