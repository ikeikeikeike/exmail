// buttons utility
'use strict';

$(function() {

  $('.btn.on-off-able').on('click tap', function () {
    const
      $this = $(this), $btn = $this.button('loading'),
      post = (action) => {
        console.log('TODO: Will be saved to ' + action || "");
      },
      main = () => {
        if ($this.is('.onable')) {
          $this
            .addClass('btn-default')
            .removeClass('btn-primary')
            .removeClass('outline');

          post($this.data('off'));
        } else {
          $this
            .addClass('btn-primary')
            .addClass('outline')
            .removeClass('btn-default');

          post($this.data('on'));
        }

        $this.toggleClass('onable');
        $btn.button('reset')
      };

    setTimeout(main, 1000);
  })

});
