$(function(){
    $('.edit_response input[type=checkbox]').click(function() {
        $(this).parent('form').submit();
    
    });

});