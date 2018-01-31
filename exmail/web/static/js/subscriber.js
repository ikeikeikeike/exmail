// subscriber checkbox to delete.
'use strict';

$(function() {
  const selector = 'input[name^=ids][type=checkbox]'

  $('.delete-subscribers').parent('form').click(function() {
    $(this).find(selector).remove();
    $(selector).clone().appendTo(this);
    $(this).find(selector).addClass('hide');
  });

  $("#checkAll").click(function() {
    $(".check").prop('checked', $(this).prop('checked'));
  });

});
