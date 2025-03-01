<#ftl output_format="HTML">
<#--
 Copyright 2016 Kafdrop contributors.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<#import "/spring.ftl" as spring />
<#import "lib/template.ftl" as template>
<@template.header "Topic: ${topic.name}: Messages">
    <style type="text/css">
        h1 {
            margin-bottom: 16px;
        }

        #messageFormPanel {
            margin-top: 16px;
        }

        #partitionSizes {
            margin-left: 16px;
        }

        .toggle-msg {
            float: left;
        }
    </style>

    <script src="<@spring.url '/js/message-inspector.js'/>"></script>
</@template.header>
<#setting number_format="0">


<h2>Topic Messages: <a href="<@spring.url '/topic/${topic.name}'/>">${topic.name}</a></h2>

<#assign selectedPartition=messageForm.partition!0?number>
<#assign selectedFormat=messageForm.format!defaultFormat>

<div id="partitionSizes">
    <#assign curPartition=topic.getPartition(selectedPartition).get()>
    <span class="badge badge-light">First Offset:</span> <span id="firstOffset">${curPartition.firstOffset}</span>&nbsp;
    <span class="badge badge-light">Last Offset:</span> <span id="lastOffset">${curPartition.size}</span>&nbsp;
    <span class="badge badge-light">Size:</span> <span
            id="partitionSize">${curPartition.size - curPartition.firstOffset}</span>
</div>

<div id="messageFormPanel" class="card">
    <form method="GET" action="<@spring.url '/topic/${topic.name}/messages'/>" id="messageForm" class="form-inline card-body">
        <div class="form-group">
            <label for="partition">Partition</label>
            <select class="form-control" id="partition" name="partition">
                <#list topic.partitions as p>
                    <option value="${p.id}" data-first-offset="${p.firstOffset}" data-last-offset="${p.size}"
                            <#if p.id == selectedPartition>selected="selected"</#if>>${p.id}</option>
                </#list>
            </select>
        </div>
        &nbsp;&nbsp;
        <@spring.bind path="messageForm.offset"/>
        <div class="form-group ${spring.status.error?string("has-error", "")}">
            <label class="control-label" for="offset">Offset</label>
            <@spring.formInput path="messageForm.offset" attributes='class="form-control"'/>
            <#if spring.status.error>
                <span class="text-danger"><i class="fa fa-times-circle"></i><@spring.showErrors "<br/>"/></span>
            </#if>
        </div>
        &nbsp;&nbsp;
        <@spring.bind path="messageForm.count"/>
        <div class="form-group ${spring.status.error?string("has-error", "")}">
            <label class=control-label" for="count"># messages</label>
            <@spring.formInput path="messageForm.count" attributes='class="form-control ${spring.status.error?string("has-error", "")}"'/>
            <#if spring.status.error>
                <span class="text-danger"><i class="fa fa-times-circle"></i><@spring.showErrors "<br/>"/></span>
            </#if>
        </div>
        &nbsp;&nbsp;
        <div class="form-group">
            <label for="format">Message format</label>
            <select class="form-control" id="format" name="format">
                <#list messageFormats as f>
                    <option value="${f}" <#if f == selectedFormat>selected="selected"</#if>>${f}</option>
                </#list>
            </select>
        </div>
        &nbsp;&nbsp;

        <button class="btn btn-success" type="submit"><i class="fa fa-search"></i> View Messages</button>
    </form>
</div>

<@spring.bind path="messageForm.*"/>
<div id="message-display" class="container">
    <#if messages?? && messages?size gt 0>
        <#list messages as msg>
            <#assign offset=messageForm.offset + msg_index>
            <div data-offset="${offset}" class="message-detail">
                <span class="badge badge-light">Offset:</span> ${offset} &nbsp;
                <span class="badge badge-light">Key:</span> ${msg.key!''} &nbsp;
                <span class="badge badge-light">Timestamp:</span> ${msg.timestamp?string('yyyy-MM-dd HH:mm:ss.SSS')}
                <span class="badge badge-light">Headers:</span> ${msg.headersFormatted}
                <div>
                    <a href="#" class="toggle-msg"><i class="fa fa-chevron-circle-right">&nbsp;</i></a>
                    <pre class="message-body">${msg.message!''}</pre>
                </div>
            </div>
        </#list>
    <#elseif !(spring.status.error) && !(messageForm.empty)>
        No messages found in partition ${(messageForm.partition)!"PARTITION_NOT_SET"} at offset ${messageForm.offset}
    </#if>
</div>

<@template.footer/>