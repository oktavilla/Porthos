Event.onReady(function() {
  if (tag_text_field = $('tag_collection_tag_names')) {
    new Porthos.TagAutoCompletion(tag_text_field);
  }
});