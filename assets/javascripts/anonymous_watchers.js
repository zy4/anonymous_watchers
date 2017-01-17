function anonymousWatch(text, defaultValue, href) {
  var msg = prompt(text, defaultValue);
  if (!msg || !msg.length) {
    return false;
  }
  if (typeof jQuery != 'undefined') {
    $.post(href, {mail: msg}, null, 'script');
  } else {
    new Ajax.Request(href, {method: 'post', parameters: {mail: msg}});
  }
  return false;
}

function anonymousUnwatch(href) {
  if (typeof jQuery != 'undefined') {
    $.post(href, null, null, 'script');
  } else {
    new Ajax.Request(href, {method: 'post'});
  }
  return false;
}

