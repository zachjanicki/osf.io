<%inherit file="project/project_base.mako"/>

<%
    import json
    is_project = node['node_type'] == 'project'
%>

% if node['is_registration']:
    <div class="alert alert-info">This ${node['node_type']} is a registration of <a class="alert-link" href="${node['registered_from_url']}">this ${node['node_type']}</a>; the content of the ${node['node_type']} has been frozen and cannot be edited.
    </div>
    <style type="text/css">
    .watermarked {
        background-image:url('/static/img/read-only.png');
        background-repeat:repeat;
    }
    </style>
% endif

<div id="projectScope">
    <header class="subhead" id="overview">
        <div class="row">
            <div class="col-sm-6 col-md-7 cite-container">
                % if parent_node['id']:
                    % if parent_node['can_view'] or parent_node['is_public'] or parent_node['is_contributor']:
                        <h1 class="node-parent-title">
                            <a href="${parent_node['url']}">${parent_node['title']}</a>&nbsp;/
                        </h1>
                    % else:
                        <h1 class="node-parent-title unavailable">
                            <span>Private Project</span>&nbsp;/
                        </h1>
                    % endif
                % endif
                <h1 class="node-title">
                    <span id="nodeTitleEditable" class="overflow">${node['title']}</span>
                </h1>
            </div>
            <div class="col-sm-6 col-md-5">
                <div class="btn-toolbar node-control pull-right">
                    <div class="btn-group">
                    % if not node["is_public"]:
                        <button class='btn btn-default disabled'>Private</button>
                        % if 'admin' in user['permissions']:
                            <a class="btn btn-default" data-bind="click: makePublic">Make Public</a>
                        % endif
                    % else:
                        % if 'admin' in user['permissions']:
                            <a class="btn btn-default" data-bind="click: makePrivate">Make Private</a>
                        % endif
                        <button class="btn btn-default disabled">Public</button>
                    % endif
                    </div>
                    <!-- ko if: canBeOrganized -->
                    <div class="btn-group" style="display: none" data-bind="visible: true">

                        <!-- ko ifnot: inDashboard -->
                           <a data-bind="click: addToDashboard, tooltip: {title: 'Add to Dashboard Folder',
                            placement: 'bottom'}" class="btn btn-default">
                               <i class="icon-folder-open"></i>
                               <i class="icon-plus"></i>
                           </a>
                        <!-- /ko -->
                        <!-- ko if: inDashboard -->
                           <a data-bind="click: removeFromDashboard, tooltip: {title: 'Remove from Dashboard Folder',
                            placement: 'bottom'}" class="btn btn-default">
                               <i class="icon-folder-open"></i>
                               <i class="icon-minus"></i>
                           </a>
                        <!-- /ko -->

                    </div>
                    <!-- /ko -->
                    <div class="btn-group">
                        <a
                        % if user_name and (node['is_public'] or user['is_contributor']) and not node['is_registration']:
                            data-bind="click: toggleWatch, tooltip: {title: watchButtonAction, placement: 'bottom'}"
                            class="btn btn-default"
                        % else:
                            class="btn btn-default disabled"
                        % endif
                            href="#">
                            <i class="icon-eye-open"></i>
                            <span data-bind="text: watchButtonDisplay" id="watchCount"></span>
                        </a>
                        <a rel="tooltip" title="Duplicate"
                            class="btn btn-default${ '' if is_project else ' disabled'}" href="#"
                            data-toggle="modal" data-target="#duplicateModal">
                            <span class="glyphicon glyphicon-share"></span>&nbsp; ${ node['templated_count'] + node['fork_count'] + node['points'] }
                        </a>
                    </div>
                    % if 'badges' in addons_enabled and badges and badges['can_award']:
                        <div class="btn-group">
                            <button class="btn btn-success" id="awardBadge" style="border-bottom-right-radius: 4px;border-top-right-radius: 4px;">
                                <i class="icon-plus"></i> Award
                            </button>
                        </div>
                    % endif
                </div>
            </div>
        </div>
        <div id="contributors" class="row" style="line-height:25px">
            <div class="col-sm-12">
                Contributors:
                % if node['anonymous'] and not node['is_public']:
                    <ol>Anonymous Contributors</ol>
                % else:
                    <ol>
                        <div mod-meta='{
                            "tpl": "util/render_contributors.mako",
                            "uri": "${node["api_url"]}get_contributors/",
                            "replace": true
                        }'></div>
                    </ol>
                % endif
                % if node['is_fork']:
                    <br />Forked from <a class="node-forked-from" href="/${node['forked_from_id']}/">${node['forked_from_display_absolute_url']}</a> on
                    <span data-bind="text: dateForked.local, tooltip: {title: dateForked.utc}"></span>
                % endif
                % if node['is_registration'] and node['registered_meta']:
                    <br />Registration Supplement:
                    % for meta in node['registered_meta']:
                        <a href="${node['url']}register/${meta['name_no_ext']}">${meta['name_clean']}</a>
                    % endfor
                % endif
                <br />Date Created:
                <span data-bind="text: dateCreated.local, tooltip: {title: dateCreated.utc}" class="date node-date-created"></span>
                | Last Updated:
                <span data-bind="text: dateModified.local, tooltip: {title: dateModified.utc}" class="date node-last-modified-date"></span>
                % if parent_node['id']:
                    <br />Category: <span class="node-category">${node['category']}</span>
                % elif node['description'] or 'write' in user['permissions']:
                    <br /><span id="description">Description:</span> <span id="nodeDescriptionEditable" class="node-description overflow" data-type="textarea">${node['description']}</span>
                % endif
            </div>
        </div>
        
    </header>
</div>


<%def name="title()">${node['title']}</%def>

<%include file="project/modal_add_pointer.mako"/>

% if node['node_type'] == 'project':
    <%include file="project/modal_add_component.mako"/>
% endif

% if user['can_comment'] or node['has_comments']:
    <%include file="include/comment_template.mako"/>
% endif

<div class="row">

    <div class="col-sm-6 osf-dash-col">

        % if addons:

            <!-- Show widgets in left column if present -->
            % for addon in addons_enabled:
                % if addons[addon]['has_widget']:
                    %if addon == 'wiki':
                        %if user['show_wiki_widget']:
                            <div class="addon-widget-container" mod-meta='{
                            "tpl": "../addons/wiki/templates/wiki_widget.mako",
                            "uri": "${node['api_url']}wiki/widget/"
                        }'></div>
                        %endif

                    %else:
                    <div class="addon-widget-container" mod-meta='{
                            "tpl": "../addons/${addon}/templates/${addon}_widget.mako",
                            "uri": "${node['api_url']}${addon}/widget/"
                        }'></div>
                    %endif
                % endif
            % endfor

        % else:
            <!-- If no widgets, show components -->
            ${children()}

        % endif

        <div class="addon-widget-container">
            <div class="addon-widget-header clearfix"> 
                <h4>Files</h4>
                <div class="pull-right">
                   <a href="${node['url']}files/" class="btn"> <i class="icon icon-external-link"></i> </a>
                </div>
            </div>
            <div class="addon-widget-body">
                <div id="treeGrid">
                    <div class="fangorn-loading"> 
                        <i class="icon-spinner fangorn-spin"></i> <p class="m-t-sm fg-load-message"> Loading files...  </p> 
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 osf-dash-col">

        <!-- Citations -->
        % if not node['anonymous']:
        <div class="citations addon-widget-container" >
            <div class="addon-widget-header clearfix"> 
                <h4>Citation <small>${node['display_absolute_url']}</small></h4>
                <div class="pull-right">
                  <a href="#" class="btn project-toggle"><i class="icon icon-angle-down"></i></a>
                </div>
            </div>
            <div class="addon-widget-body" style="display : none;">
                <dl class="citation-list">
                    <dt>APA</dt>
                        <dd class="citation-text">${node['citations']['apa']}</dd>
                    <dt>MLA</dt>
                        <dd class="citation-text">${node['citations']['mla']}</dd>
                    <dt>Chicago</dt>
                        <dd class="citation-text">${node['citations']['chicago']}</dd>
                </dl>
            </div> 
        </div>

        % endif

        <!-- Show child on right if widgets -->
        % if addons:
            ${children()}
        % endif


        %if node['tags'] or 'write' in user['permissions']:
         <div class="tags addon-widget-container">
            <div class="addon-widget-header clearfix"> 
                <h4>Tags </h4>
                <div class="pull-right">
                </div>
            </div>
            <div class="addon-widget-body">
                <input name="node-tags" id="node-tags" value="${','.join([tag for tag in node['tags']]) if node['tags'] else ''}" />
            </div> 
        </div>

        %endif


        <%include file="log_list.mako"/>

    </div>

</div>

<%def name="children()">
% if node['node_type'] == 'project':
     <div class="components addon-widget-container">
        <div class="addon-widget-header clearfix"> 
            <h4>Components </h4>
            <div class="pull-right">
              % if 'write' in user['permissions'] and not node['is_registration']:
                    <a class="btn btn-sm btn-default" data-toggle="modal" data-target="#newComponent">Add Component</a>
                    <a class="btn btn-sm btn-default" data-toggle="modal" data-target="#addPointer">Add Links</a>
                % endif

            </div>
        </div>
        <div class="addon-widget-body">
              % if node['children']:
                  <div id="containment">
                      <div mod-meta='{
                              "tpl": "util/render_nodes.mako",
                              "uri": "${node["api_url"]}get_children/",
                              "replace": true,
                      "kwargs": {"sortable" : ${'true' if not node['is_registration'] else 'false'}}
                          }'></div>
                  </div>
              % else:
                <p>No components have been added to this project.</p>
              % endif

        </div> 
    </div>
% endif

% for name, capabilities in addon_capabilities.iteritems():
    <script id="capabilities-${name}" type="text/html">${capabilities}</script>
% endfor

</%def>

<%def name="stylesheets()">
    ${parent.stylesheets()}
    % for style in addon_widget_css:
    <link rel="stylesheet" href="${style}" />
    % endfor
    % for stylesheet in tree_css:
    <link rel='stylesheet' href='${stylesheet}' type='text/css' />
    % endfor
</%def>

<%def name="javascript_bottom()">
<% import json %>

${parent.javascript_bottom()}

% for script in tree_js:
<script type="text/javascript" src="${script | webpack_asset}"></script>
% endfor

<script type="text/javascript">
    // Hack to allow mako variables to be accessed to JS modules

    window.contextVars = $.extend(true, {}, window.contextVars, {
        currentUser: {
            name: '${user_full_name | js_str}',
            canComment: ${json.dumps(user['can_comment'])},
            canEdit: ${json.dumps(user['can_edit'])}
        },
        node: {
            hasChildren: ${json.dumps(node['has_children'])},
            isRegistration: ${json.dumps(node['is_registration'])},
            tags: ${json.dumps(node['tags'])}
        }
    });
</script>

<script src="${"/static/public/js/project-dashboard.js" | webpack_asset}"></script>

% for asset in addon_widget_js:
<script src="${asset | webpack_asset}"></script>
% endfor

</%def>