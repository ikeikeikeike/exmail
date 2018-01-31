// Simple editor
'use strict';

import * as toast from "./utils/toast";
import * as markup from "./utils/markup";
import * as consts from "./utils/consts";


$(function() {

if ($('.confirm-config').length <= 0) {
  return;
}

// const configs = Array.prototype.map.call(
  // document.querySelectorAll(".confirm-config"), elm => $(elm).data()
// )

// class Validation {

  // constructor(html, cfg) {
    // this._html  = html;
    // this._cfg   = cfg;
  // }

  // defaultTextContent() {
    // let r = true;

    // if (this._cfg.trackOpen) {
      // r = this._html.includes(this._cfg.trackOpenHolder);
    // }

    // // TODO:
    // // if (this._cfg.trackTextClick) {
      // // r = this._html.includes(this._cfg.trackTextClickHolder);
    // // }

    // if (this._cfg.trackHtmlClick) {
      // r = this._html.includes(this._cfg.trackHtmlClickHolder);
    // }

    // return r;
  // }

  // valid() {
    // let result;
    // result = this.defaultTextContent();
    // // result = result && this.another1();
    // // result = result && this.another2();
    // return result
  // }

// }


// class Message {
  // constructor() {
    // consts.classConst(this, 'SUCCESS_ICON', 'fa fa-check-square-o fa-2x text-success');
    // consts.classConst(this, 'FAILURE_ICON', 'fa fa-exclamation-triangle fa-2x text-danger');
    // consts.classConst(this, 'SUCCESS_MESSAGE', 'You’re all set to send!');       // TODO: gettext
    // consts.classConst(this, 'FAILURE_MESSAGE', 'Looks like there’s a problem');  // TODO: gettext
  // }

  // defaultTextContent(bool) {
    // const $check = $('.media[data-check="default-text-content"]');
    // if ($check.length <= 0) {
      // return;
    // }

    // const
      // $icon = $check.find('.media-heading i'),
      // $text = $check.find('.media-body');

    // $icon.removeAttr('class');
    // $text.find("p").remove();

    // if (bool) {
      // $icon.addClass(this.SUCCESS_ICON);
      // $text.append("<p>Edited content already</p>");
    // } else {
      // $icon.addClass(this.FAILURE_ICON);
      // $text.append("<p>No editing content yet</p>");
    // }
  // }

  // sendButton(bool) {
    // $('#send-button').attr('disabled', !bool);
  // }
// }

// class Fallback {
  // constructor(elm, alt, regenerateText) {
    // // Set alternative email-content
    // if (alt) document.getElementById("fallback-area").value = alt;
    // if (regenerateText) document.getElementById("fallback-regenerate").value = regenerateText;
  // }

  // saveDocument() {
    // const form = $('#fallback-form');
    // let data = {body: $('#fallback-area').val()};

    // form.serializeArray().map((x) => data[x.name] = x.value)

    // $.ajax({
      // url: form.attr('action'),
      // type: "POST",
      // data: data,
      // success: msg => {
        // toast.info("Plain-Text Email changed!");
      // },
    // });
  // };

  // listener() {
    // const me = this;
    // $('#fallback-submit').on('click', function() {
      // me.saveDocument();
    // })
    // $('#fallback-regenerate').on('click', function() {
      // document.getElementById("fallback-area").value = this.value;
    // })
  // }
// }

// configs.forEach(cfg => {
  // const main = (alt) => {$.get(cfg.tpl, (html) => {
    // console.log(cfg)
    // const fallback = new Fallback(alt, markup.generateText(html));
      // // message    = new Message();
      // // validation = new Validation(html, globalConfig);

    // fallback.listener();

    // // message.defaultTextContent(validation.defaultTextContent());
    // // message.sendButton(validation.valid());

  // });};

  // if (cfg.alt) {
    // $.get(cfg.alt, main);
  // } else {
    // main();
  // }
// });



const saveDocument = elm => {
  const form = $(elm).parents('form')
  let   data = {body: form.find('.fallback-area').val()};

  form.serializeArray().map((x) => data[x.name] = x.value)

  $.ajax({
    url: form.attr('action'),
    type: "POST",
    data: data,
    success: msg => {
      toast.info("Plain-Text Email changed!");
    },
  });
};

$('.fallback-submit').on('click', function() {
  saveDocument(this);
})
// $('.fallback-regenerate').on('click', function() {
  // $(this).parents('form').find('.fallback-area').val(this.value)
// })


});
