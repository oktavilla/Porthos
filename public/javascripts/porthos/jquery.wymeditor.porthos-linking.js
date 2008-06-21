$(document).ready(function() {
  if($('.wym_dialog_link')){
    $.ajax({
      url: Routes.formatted_admin_nodes('js'),
      success: function(result){
        $('#navigation').html('<ul id="nodes">'+result+"</ul>");
        setup_nodes('navigation');
      }
    });
    $('#toggle_assets').click(function() {
      if (this.className != 'current') {
        $('#toggle_navigation').trigger('click');
        this.className = 'current';
        $.ajax({
          url: Routes.formatted_admin_assets('js'),
          success: function(result){
            $('#assets').html(result);
            setup_assets();
          }
        });
      } else {
        this.className = '';
      }
      $('#assets').toggle();
      return false;
    });
    $('#toggle_navigation').click(function() {
      if (this.className != 'current') {
        $('#toggle_assets').trigger('click');
        this.className = 'current';
      } else {
        this.className = '';
      }
      $('#navigation').toggle();
      return false;
    });
  }
});


function setup_assets() {
  $(".assets li").click(function() {
    var id = $(this).attr('id').replace(/([A-z]|\_|\-)*/i, '');
    $.getJSON(Routes.formatted_admin_asset(id, 'js'),
      function(asset) {
        $('input.wym_href:first').val(Routes.download_asset(asset.file_name, asset.extname));
        $('input.wym_title:first').val(asset.title);
      }
    );
  });
  
  $(".assets li").hover(
    function() {
      $(this).find('.meta').css('visibility','visible'); 
    },
    function() {
      $(this).find('.meta').css('visibility','hidden');
    }
  );
  
  $('#upload_asset_form').attr('action', $('#upload_asset_form').attr('action')+'.js');
  var options = { success: handle_response, error : show_error };
  $('#upload_asset_form').submit(function()  {$(this).ajaxSubmit(options);return false;});
  
  $("form.search_assets input").show();
  $("form.search_assets").submit(function() {
    $.get(this.action+'.js', { 'query': $('form.search_assets input[@name=query]').val() }, function(result) {
      $('#assets').html(result);
      setup_assets();
    });
    return false;
  });
  
  $('.pagination a').click(function(){
    $.ajax({
      url: this.href,
      success: function(result){
        $('#assets').html(result);
        setup_assets();
      }
    });
    return false;
  });
}

function handle_response(responseText){ 
  responseText = responseText.replace(/<pre>/,'');
  responseText = responseText.replace(/<\/pre>/,'');
  var asset = eval(responseText)[0];
  var li = '<li id="asset_'+asset.id+'" class="asset">';
  if(asset.type == 'ImageAsset'){
    li += '<img src="/images/c87x87/'+asset.file_name+'.'+asset.extname+'" id="asset_'+asset.id+'" alt=""/>';
  }else{
    li += '<span class="icon '+asset.extname+'"/></span>';
  }
  li += '<div class="meta" style="visibility: hidden;">';
  li += '<span class="title">Titel: <span class="value">'+asset.title+'</span></span>';
  li += '<span class="cerated_at">Uppladdad: <span class="value">'+asset.created_at+'</span></span>';
  li += '<span class="file_name">Filnamn: <span class="value">'+asset.file_name+'.'+asset.extname+'</span></span></div></li>';
  
  $('ul.assets').prepend(li);
  setup_assets()
}

function show_error(text, b) {
}

function setup_nodes(parent_id){
  $('.handle').remove();
  $('.settings').removeClass('settings').hide();

  $('#'+ parent_id+' a.toggle_handle').click(function() {
    toggle(this);
    return false;
  });
  
  $('#nodes li > div').click(function() {
    var node_id = $(this).parent('li.node').attr('id').replace(/([A-z]|\_|\-)*/i, '');
    $.getJSON(Routes.formatted_admin_node(node_id, 'js'),
      function(data) {
        $('input.wym_href:first').val('/'+data.slug); 
      }
    );
    return false;
  });
}

function toggle(el) {  
  !el.open ? expand(el) : contract(el);
}

function expand(el) {
  if (!el.has_nodes) {
    $.ajax({
      url: el.href,
      data: {'format':'js'},
      success: function(result) {
        parent = $(el).parent().parent('li.node');
        var list_id = 'children_of_'+parent.attr('id');
        parent.append('<ul id="'+list_id+'">'+result+'</ul>');
        el.has_nodes = true;
        setup_nodes(list_id);
      }
    });
  } else {
    $(el).parent().siblings('ul').show();
  }
  $(el).text('-');
  $(el).addClass("active");
  el.open = true;
}

function contract(el){

  $(el).text('+').parent().siblings('ul').hide();
  $(el).removeClass("active");
  el.open = false;
}