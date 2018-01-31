// file upload, should transfer to it will create js module.
'use strict';

import * as toast from "./utils/toast";

$(function() {

  const fp = flatpickr(".flatpickr", {enableTime: true, clickOpens: false, dateFormat: 'Y-m-dTH:i:00+09:00'});
  $('.flatpickr').on('click tap', function() {
    fp.open();
  })

  const urlFor = () => {
    let attachEvent, clean_url, linkTo;

    clean_url = (url) => url

    linkTo = () => {
      return $('body').find('[url-for]').each(function(index) {
        const $this = $(this);
        $this.addClass('pointer');

        return $this.off('click').on('click', function(e) {
          let w, url = clean_url($(this).attr('url-for'));

          // happend error in phoenix router
          // if (document.referrer) {
            // var referrer = "referrer=" + encodeURIComponent(document.referrer);
            // url = url + (location.search ? '&' : '?') + referrer;
          // }

          if ($(this).attr('target') === '_blank') {
            w = window.open();
            w.location.href = url;
            return;
          }

          if (e.ctrlKey || e.metaKey) {
            w = window.open();
            w.location.href = url;
            return;
          }

          location.href = url;
        });
      });
    };

    attachEvent = () => {

      /* Event */
      linkTo();
      return $('html, body').ajaxStart(function() {
        return linkTo();
      }).ajaxStop(function() {
        return linkTo();
      }).ajaxComplete(function() {
        return linkTo();
      });
    };

    attachEvent();
  };

  urlFor();


  // file open
  //
  $('#lefile input[type=file]').on("change", function() {
    $('#lefile input[type=text]').val($(this).val().replace("C:\\fakepath\\", ""));
  });

  $('#lefile button[type=button]').on('click', function() {
    $('#lefile input[type=file]').click();
  });


  // Load tooltip
  //
  $('[data-toggle="tooltip"]').tooltip();


  // Checkbox
  //
  const elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));
  elems.forEach(function(html) {
    new Switchery(html, {color: "#337ab7"});
  });


  // Toast message
  //
  $('script.notification-message[data-error]').each(function() {
    toast.error($(this).data('error'));
  });
  $('script.notification-message[data-info]').each(function() {
    toast.info($(this).data('info'));
  });
  $('script.notification-message[data-warn]').each(function() {
    toast.warn($(this).data('warn'));
  });
  $('script.notification-message[data-success]').each(function() {
    toast.success($(this).data('success'));
  });


  // Initializes and creates emoji set from sprite sheet
  //
  window.emojiPicker = new EmojiPicker({
    emojiable_selector: '[data-emojiable=true]',
    assetsPath: '/img/',
    popupButtonClasses: 'fa fa-smile-o'
  });
  // Finds all elements with `emojiable_selector` and converts them to rich emoji input fields
  // You may want to delay this step if you have dynamically created input fields that appear later in the loading process
  // It can be called as many times as necessary; previously converted input fields will not be converted again
  window.emojiPicker.discover();

});
