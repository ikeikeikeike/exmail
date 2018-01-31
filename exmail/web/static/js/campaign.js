// campaign radio
'use strict';

$(function() {
  const sel = 'input[name^=recipient_][type=radio],[data-target^="#recipient-radio"]';

  $(sel).on('click check', function() {
    const radios = $(this).parents('.middle').find('.media').next('[id^="recipient-radio"]'),
          eachform = radios.find('[id^=save-recipient-]').parent('form');

    eachform.find('[type=radio]').remove();
    radios.find('[id^=inlineRadio]').clone().appendTo(eachform);
    eachform.find('[type="radio"]').addClass('hide');

    eachform.find('a.btn').addClass('disabled');
    radios  // fuck off this code!!
    .find('input[id^=inlineRadio]:checked')
    .parent('label')
    .parents('.collapse')
    .find('a.btn')
    .removeClass('disabled');
  });

  $('.timer').startTimer({
    onComplete: function(element){
      element.addClass('is-complete');
    }
  });

 });
