
$(function() {
    $('#container').eq(0).addEventListener('gestureend', function(e) {
        if (e.scale < 1.0) {
            alert('in');
        } else if (e.scale > 1.0) {
            alert('out')
        }
    }, false);
});
