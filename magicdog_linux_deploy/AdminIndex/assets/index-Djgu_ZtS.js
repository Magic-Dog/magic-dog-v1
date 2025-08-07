import{L as le,e1 as ce,Q as c,S as M,V as N,R as f,d as W,W as Y,X as Z,bf as de,a2 as _,aS as me,aT as ue,co as ge,a as L,a0 as P,c_ as xe,a1 as fe,a6 as K,a5 as A,r as g,i as pe,as as ve,o as b,b as w,e as t,f as k,w as y,cu as E,t as x,h as C,H as ye,J as he,I as be,af as G,ae as $,B as J,g as Q,T as X,C as _e,e2 as we,e3 as ze,e4 as ke,e5 as Ce,c as $e,cy as Se}from"./index-Czrv2civ.js";import{u as Te}from"./use-houdini-Dvoi_2Fj.js";function Be(s){const{textColor3:o,infoColor:l,errorColor:d,successColor:r,warningColor:m,textColor1:p,textColor2:v,railColor:S,fontWeightStrong:T,fontSize:V}=s;return Object.assign(Object.assign({},ce),{contentFontSize:V,titleFontWeight:T,circleBorder:`2px solid ${o}`,circleBorderInfo:`2px solid ${l}`,circleBorderError:`2px solid ${d}`,circleBorderSuccess:`2px solid ${r}`,circleBorderWarning:`2px solid ${m}`,iconColor:o,iconColorInfo:l,iconColorError:d,iconColorSuccess:r,iconColorWarning:m,titleTextColor:p,contentTextColor:v,metaTextColor:o,lineColor:S})}const Ve={name:"Timeline",common:le,self:Be},q=1.25,Me=c("timeline",`
 position: relative;
 width: 100%;
 display: flex;
 flex-direction: column;
 line-height: ${q};
`,[M("horizontal",`
 flex-direction: row;
 `,[N(">",[c("timeline-item",`
 flex-shrink: 0;
 padding-right: 40px;
 `,[M("dashed-line-type",[N(">",[c("timeline-item-timeline",[f("line",`
 background-image: linear-gradient(90deg, var(--n-color-start), var(--n-color-start) 50%, transparent 50%, transparent 100%);
 background-size: 10px 1px;
 `)])])]),N(">",[c("timeline-item-content",`
 margin-top: calc(var(--n-icon-size) + 12px);
 `,[N(">",[f("meta",`
 margin-top: 6px;
 margin-bottom: unset;
 `)])]),c("timeline-item-timeline",`
 width: 100%;
 height: calc(var(--n-icon-size) + 12px);
 `,[f("line",`
 left: var(--n-icon-size);
 top: calc(var(--n-icon-size) / 2 - 1px);
 right: 0px;
 width: unset;
 height: 2px;
 `)])])])])]),M("right-placement",[c("timeline-item",[c("timeline-item-content",`
 text-align: right;
 margin-right: calc(var(--n-icon-size) + 12px);
 `),c("timeline-item-timeline",`
 width: var(--n-icon-size);
 right: 0;
 `)])]),M("left-placement",[c("timeline-item",[c("timeline-item-content",`
 margin-left: calc(var(--n-icon-size) + 12px);
 `),c("timeline-item-timeline",`
 left: 0;
 `)])]),c("timeline-item",`
 position: relative;
 `,[N("&:last-child",[c("timeline-item-timeline",[f("line",`
 display: none;
 `)]),c("timeline-item-content",[f("meta",`
 margin-bottom: 0;
 `)])]),c("timeline-item-content",[f("title",`
 margin: var(--n-title-margin);
 font-size: var(--n-title-font-size);
 transition: color .3s var(--n-bezier);
 font-weight: var(--n-title-font-weight);
 color: var(--n-title-text-color);
 `),f("content",`
 transition: color .3s var(--n-bezier);
 font-size: var(--n-content-font-size);
 color: var(--n-content-text-color);
 `),f("meta",`
 transition: color .3s var(--n-bezier);
 font-size: 12px;
 margin-top: 6px;
 margin-bottom: 20px;
 color: var(--n-meta-text-color);
 `)]),M("dashed-line-type",[c("timeline-item-timeline",[f("line",`
 --n-color-start: var(--n-line-color);
 transition: --n-color-start .3s var(--n-bezier);
 background-color: transparent;
 background-image: linear-gradient(180deg, var(--n-color-start), var(--n-color-start) 50%, transparent 50%, transparent 100%);
 background-size: 1px 10px;
 `)])]),c("timeline-item-timeline",`
 width: calc(var(--n-icon-size) + 12px);
 position: absolute;
 top: calc(var(--n-title-font-size) * ${q} / 2 - var(--n-icon-size) / 2);
 height: 100%;
 `,[f("circle",`
 border: var(--n-circle-border);
 transition:
 background-color .3s var(--n-bezier),
 border-color .3s var(--n-bezier);
 width: var(--n-icon-size);
 height: var(--n-icon-size);
 border-radius: var(--n-icon-size);
 box-sizing: border-box;
 `),f("icon",`
 color: var(--n-icon-color);
 font-size: var(--n-icon-size);
 height: var(--n-icon-size);
 width: var(--n-icon-size);
 display: flex;
 align-items: center;
 justify-content: center;
 `),f("line",`
 transition: background-color .3s var(--n-bezier);
 position: absolute;
 top: var(--n-icon-size);
 left: calc(var(--n-icon-size) / 2 - 1px);
 bottom: 0px;
 width: 2px;
 background-color: var(--n-line-color);
 `)])])]),Ne=Object.assign(Object.assign({},Z.props),{horizontal:Boolean,itemPlacement:{type:String,default:"left"},size:{type:String,default:"medium"},iconSize:Number}),ee=me("n-timeline"),Pe=W({name:"Timeline",props:Ne,setup(s,{slots:o}){const{mergedClsPrefixRef:l}=Y(s),d=Z("Timeline","-timeline",Me,Ve,s,l);return de(ee,{props:s,mergedThemeRef:d,mergedClsPrefixRef:l}),()=>{const{value:r}=l;return _("div",{class:[`${r}-timeline`,s.horizontal&&`${r}-timeline--horizontal`,`${r}-timeline--${s.size}-size`,!s.horizontal&&`${r}-timeline--${s.itemPlacement}-placement`]},o)}}}),je={time:[String,Number],title:String,content:String,color:String,lineType:{type:String,default:"default"},type:{type:String,default:"default"}},Ie=W({name:"TimelineItem",props:je,setup(s){const o=ue(ee);o||ge("timeline-item","`n-timeline-item` must be placed inside `n-timeline`."),Te();const{inlineThemeDisabled:l}=Y(),d=L(()=>{const{props:{size:m,iconSize:p},mergedThemeRef:v}=o,{type:S}=s,{self:{titleTextColor:T,contentTextColor:V,metaTextColor:B,lineColor:h,titleFontWeight:j,contentFontSize:z,[P("iconSize",m)]:F,[P("titleMargin",m)]:I,[P("titleFontSize",m)]:D,[P("circleBorder",S)]:R,[P("iconColor",S)]:U},common:{cubicBezierEaseInOut:H}}=v.value;return{"--n-bezier":H,"--n-circle-border":R,"--n-icon-color":U,"--n-content-font-size":z,"--n-content-text-color":V,"--n-line-color":h,"--n-meta-text-color":B,"--n-title-font-size":D,"--n-title-font-weight":j,"--n-title-margin":I,"--n-title-text-color":T,"--n-icon-size":xe(p)||F}}),r=l?fe("timeline-item",L(()=>{const{props:{size:m,iconSize:p}}=o,{type:v}=s;return`${m[0]}${p||"a"}${v[0]}`}),d,o.props):void 0;return{mergedClsPrefix:o.mergedClsPrefixRef,cssVars:l?void 0:d,themeClass:r==null?void 0:r.themeClass,onRender:r==null?void 0:r.onRender}},render(){const{mergedClsPrefix:s,color:o,onRender:l,$slots:d}=this;return l==null||l(),_("div",{class:[`${s}-timeline-item`,this.themeClass,`${s}-timeline-item--${this.type}-type`,`${s}-timeline-item--${this.lineType}-line-type`],style:this.cssVars},_("div",{class:`${s}-timeline-item-timeline`},_("div",{class:`${s}-timeline-item-timeline__line`}),K(d.icon,r=>r?_("div",{class:`${s}-timeline-item-timeline__icon`,style:{color:o}},r):_("div",{class:`${s}-timeline-item-timeline__circle`,style:{borderColor:o}}))),_("div",{class:`${s}-timeline-item-content`},K(d.header,r=>r||this.title?_("div",{class:`${s}-timeline-item-content__title`},r||this.title):null),_("div",{class:`${s}-timeline-item-content__content`},A(d.default,()=>[this.content])),_("div",{class:`${s}-timeline-item-content__meta`},A(d.footer,()=>[this.time]))))}}),De={class:"relative min-h-500px bg-gray-50 p-6 dark:bg-gray-900"},Fe={class:"mx-auto max-w-4xl"},Re={class:"flex items-center justify-between"},Ue={class:"grid grid-cols-1 gap-6 md:grid-cols-3"},He={class:"text-xl text-gray-900 font-bold dark:text-gray-100"},Ee={class:"text-sm text-gray-900 font-mono dark:text-gray-100"},Le={class:"text-lg text-gray-900 capitalize dark:text-gray-100"},We={class:"space-y-3"},Oe={class:"flex items-center justify-between"},Ke={class:"text-lg text-gray-900 font-medium dark:text-gray-100"},Ae={class:"flex gap-2"},Ge={key:0,class:"rounded-full bg-red-100 px-2 py-1 text-xs text-red-800 dark:bg-red-900 dark:text-red-200"},Je={key:1,class:"rounded-full bg-green-100 px-2 py-1 text-xs text-green-800 dark:bg-green-900 dark:text-green-200"},Qe={class:"grid grid-cols-2 gap-4 text-sm md:grid-cols-4"},Xe={class:"ml-1 text-gray-900 font-medium capitalize dark:text-gray-100"},qe={class:"ml-1 text-gray-900 font-medium dark:text-gray-100"},Ye={class:"ml-1 text-gray-900 font-medium dark:text-gray-100"},Ze={class:"rounded-lg bg-gray-50 p-4 dark:bg-gray-700"},et={class:"mb-3 text-sm text-gray-600 dark:text-gray-400"},tt={class:"whitespace-pre-wrap text-sm text-gray-600 dark:text-gray-400"},it={class:"flex gap-2"},nt={key:0,class:"py-8 text-center"},at={key:1,class:"py-8 text-center"},st={key:2,class:"py-12 text-center"},rt={key:0,class:"fixed right-6 z-50",style:{bottom:"64px"}},ot={key:0,class:"fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"},lt={class:"mx-4 max-w-md w-full rounded-xl bg-white p-8 shadow-2xl dark:bg-gray-800"},ct={class:"text-center"},dt={class:"mb-4 text-gray-600 dark:text-gray-400"},mt={class:"mb-4 h-3 w-full rounded-full bg-gray-200 dark:bg-gray-700"},ut={class:"text-sm text-gray-500 dark:text-gray-400"},gt=W({name:"version-update",__name:"index",setup(s){const o=g(!1),l=g(!1),d=g(!1),r=g(!1),m=g(!0),p=g(0),v=g("准备更新..."),S=g(),T=g(1),V=g(10),B=g({current_version:"v0.1.0",version_name:"v0.1.0",platform:"Unknown",client_id:""}),h=g([]),j=g(null),z=L(()=>{var i;return((i=j.value)==null?void 0:i.need_update)||!1});async function F(){var i;try{const{data:e}=await we();B.value=e}catch{(i=window.$message)==null||i.error("获取当前版本信息失败")}}async function I(){var i,e,n;d.value=!0;try{const{data:a}=await ze();console.log("检查更新响应:",a),j.value=a,a!=null&&a.need_update?(i=window.$message)==null||i.info(`发现新版本可用: ${a.latest_version}`):(e=window.$message)==null||e.success("当前已是最新版本")}catch{(n=window.$message)==null||n.error("检查更新失败")}finally{d.value=!1}}async function D(i=1,e=!1){var n;e?(o.value=!0,h.value=[]):l.value=!0;try{const{data:a}=await ke({page:i,page_size:V.value});console.log("版本列表响应:",a);const{versions:u,total:re}=a;e?h.value=u:h.value.push(...u);const oe=h.value.length;m.value=oe<re}catch{(n=window.$message)==null||n.error("获取版本历史失败")}finally{o.value=!1,l.value=!1}}function R(i){const e=i.target,{scrollTop:n,scrollHeight:a,clientHeight:u}=e;n+u>=a-50&&!l.value&&m.value&&U()}async function U(){l.value||!m.value||(T.value+=1,await D(T.value,!1))}async function H(){var i,e;if(!(!z.value&&(await I(),!z.value))){r.value=!0,p.value=0,v.value="开始更新...";try{v.value="正在执行更新...";const a=(await Ce()).response.data;if((a==null?void 0:a.code)==="0000")v.value=a.msg||"更新完成，准备重启...",p.value=100,(i=window.$message)==null||i.success(a.msg||"更新完成！系统将在5秒后重启..."),setTimeout(()=>{window.location.reload()},5e3);else throw new Error((a==null?void 0:a.msg)||"更新失败")}catch(n){v.value="更新失败",(e=window.$message)==null||e.error(n.message||"更新失败，请稍后重试"),setTimeout(()=>{r.value=!1,p.value=0},3e3)}}}function te(i){var e;(e=window.$dialog)==null||e.info({title:`版本详情 - ${i.version_name}`,content:`版本类型: ${i.version_type}
平台: ${i.platform}
更新类型: ${i.update_type}
发布时间: ${se(i.publish_time)}
文件大小: ${O(i.file_size)}
状态: ${i.is_stable?"稳定版":"测试版"}

版本描述:
${i.description}

更新内容:
${i.changelog}`,positiveText:"关闭"})}function ie(i,e){return e===0?"success":i.is_force_update?"error":"info"}function O(i){if(i===0)return"0 Bytes";const e=1024,n=["Bytes","KB","MB","GB"],a=Math.floor(Math.log(i)/Math.log(e));return`${Number.parseFloat((i/e**a).toFixed(2))} ${n[a]}`}function ne(i){const e=new Date(i),a=new Date().getTime()-e.getTime(),u=Math.floor(a/(1e3*60*60*24));return u===0?"今天":u===1?"昨天":u<30?`${u}天前`:u<365?`${Math.floor(u/30)}个月前`:`${Math.floor(u/365)}年前`}function ae(i){return new Date(i).toLocaleDateString("zh-CN")}function se(i){return new Date(i).toLocaleString("zh-CN")}return pe(async()=>{await Promise.all([F(),I(),D(1,!0)])}),ve(()=>{}),(i,e)=>(b(),w("div",De,[t("div",Fe,[e[15]||(e[15]=t("div",{class:"mb-8"},[t("h1",{class:"mb-2 text-3xl text-gray-900 font-bold dark:text-gray-100"},"版本更新历史"),t("p",{class:"text-gray-600 dark:text-gray-400"},"查看系统的版本更新记录和详细信息")],-1)),k(C(ye),{class:"mb-8 border-0 shadow-sm transition-shadow hover:shadow-md"},{header:y(()=>[t("div",Re,[e[0]||(e[0]=t("div",{class:"flex items-center"},[t("div",{class:"mr-3 h-3 w-3 rounded-full bg-green-500"}),t("span",{class:"text-lg text-gray-900 font-semibold dark:text-gray-100"},"当前版本")],-1)),t("span",{class:E(["rounded-full px-3 py-1 text-sm font-medium",{"bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200":!z.value,"bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200":z.value}])},x(z.value?"有新版本可用":"已是最新版本"),3)])]),default:y(()=>[t("div",Ue,[t("div",null,[e[1]||(e[1]=t("div",{class:"mb-1 text-sm text-gray-500 dark:text-gray-400"},"版本号",-1)),t("div",He,x(B.value.current_version||"v1.1.0"),1)]),t("div",null,[e[2]||(e[2]=t("div",{class:"mb-1 text-sm text-gray-500 dark:text-gray-400"},"客户端ID",-1)),t("div",Ee,x(B.value.client_id||"Unknown"),1)]),t("div",null,[e[3]||(e[3]=t("div",{class:"mb-1 text-sm text-gray-500 dark:text-gray-400"},"平台",-1)),t("div",Le,x(B.value.platform||"Unknown"),1)])])]),_:1}),t("div",{ref_key:"timelineContainer",ref:S,class:"rounded-xl bg-white p-6 shadow-sm dark:bg-gray-800",style:{"max-height":"800px","overflow-y":"auto"},onScroll:R},[e[14]||(e[14]=t("h2",{class:"mb-6 text-xl text-gray-900 font-semibold dark:text-gray-100"},"版本更新时间线",-1)),k(C(G),{show:o.value&&h.value.length===0},{default:y(()=>[k(C(Pe),null,{default:y(()=>[(b(!0),w(he,null,be(h.value,(n,a)=>(b(),$e(C(Ie),{key:n.id,type:ie(n,a),title:n.version_name,time:ne(n.publish_time)},{icon:y(()=>[t("div",{class:E(["h-3 w-3 rounded-full",{"bg-green-500":a===0,"bg-blue-500":a>0&&!n.is_force_update,"bg-red-500":n.is_force_update}])},null,2)]),default:y(()=>[t("div",We,[t("div",Oe,[t("h3",Ke,x(n.title),1),t("div",Ae,[n.is_force_update?(b(),w("span",Ge," 强制更新 ")):$("",!0),a===0?(b(),w("span",Je," 最新版本 ")):$("",!0)])]),t("div",Qe,[t("div",null,[e[4]||(e[4]=t("span",{class:"text-gray-500 dark:text-gray-400"},"版本类型:",-1)),t("span",Xe,x(n.version_type),1)]),t("div",null,[e[5]||(e[5]=t("span",{class:"text-gray-500 dark:text-gray-400"},"文件大小:",-1)),t("span",qe,x(O(n.file_size)),1)]),t("div",null,[e[6]||(e[6]=t("span",{class:"text-gray-500 dark:text-gray-400"},"发布时间:",-1)),t("span",Ye,x(ae(n.publish_time)),1)]),t("div",null,[e[7]||(e[7]=t("span",{class:"text-gray-500 dark:text-gray-400"},"状态:",-1)),t("span",{class:E(["ml-1 font-medium",{"text-green-600 dark:text-green-400":n.is_stable,"text-orange-600 dark:text-orange-400":!n.is_stable}])},x(n.is_stable?"稳定版":"测试版"),3)])]),t("div",Ze,[e[8]||(e[8]=t("h4",{class:"mb-2 text-sm text-gray-700 font-medium dark:text-gray-300"},"版本描述",-1)),t("div",et,x(n.description),1),e[9]||(e[9]=t("h4",{class:"mb-2 text-sm text-gray-700 font-medium dark:text-gray-300"},"更新内容",-1)),t("div",tt,x(n.changelog),1)]),t("div",it,[k(C(J),{size:"small",onClick:u=>te(n)},{default:y(()=>e[10]||(e[10]=[Q("查看详情")])),_:2},1032,["onClick"])])])]),_:2},1032,["type","title","time"]))),128))]),_:1}),l.value?(b(),w("div",nt,[k(C(G),{size:"medium"}),e[11]||(e[11]=t("p",{class:"mt-2 text-gray-500 dark:text-gray-400"},"正在加载更多版本...",-1))])):$("",!0),!m.value&&h.value.length>0?(b(),w("div",at,e[12]||(e[12]=[t("p",{class:"text-gray-400 dark:text-gray-500"},"已加载全部版本历史",-1)]))):$("",!0),h.value.length===0&&!o.value?(b(),w("div",st,e[13]||(e[13]=[t("div",{class:"mb-2 text-lg text-gray-400 dark:text-gray-500"},"暂无版本历史",-1),t("div",{class:"text-sm text-gray-500 dark:text-gray-400"},"版本更新记录将会在此处显示",-1)]))):$("",!0)]),_:1},8,["show"])],544)]),k(X,{name:"fade-slide"},{default:y(()=>[z.value&&!r.value?(b(),w("div",rt,[k(C(J),{type:"primary",size:"large",round:"",class:"hover:shadow-3xl transform shadow-2xl transition-all duration-300 hover:scale-105",loading:d.value,onClick:H},{icon:y(()=>e[16]||(e[16]=[t("div",{class:"mr-2 h-5 w-5 flex items-center justify-center rounded-full bg-white bg-opacity-20"},[t("svg",{class:"h-3 w-3 text-white",fill:"currentColor",viewBox:"0 0 20 20"},[t("path",{"fill-rule":"evenodd",d:"M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-8.707l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L9 9.414V13a1 1 0 102 0V9.414l1.293 1.293a1 1 0 001.414-1.414z","clip-rule":"evenodd"})])],-1)])),default:y(()=>[e[17]||(e[17]=Q(" 更新最新版 "))]),_:1},8,["loading"])])):$("",!0)]),_:1}),k(X,{name:"fade"},{default:y(()=>[r.value?(b(),w("div",ot,[t("div",lt,[t("div",ct,[e[18]||(e[18]=t("div",{class:"mx-auto mb-4 h-16 w-16 flex items-center justify-center rounded-full bg-blue-100 dark:bg-blue-900"},[t("svg",{class:"h-8 w-8 animate-spin text-blue-600 dark:text-blue-400",fill:"none",viewBox:"0 0 24 24"},[t("circle",{class:"opacity-25",cx:"12",cy:"12",r:"10",stroke:"currentColor","stroke-width":"4"}),t("path",{class:"opacity-75",fill:"currentColor",d:"M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"})])],-1)),e[19]||(e[19]=t("h3",{class:"mb-2 text-lg text-gray-900 font-semibold dark:text-gray-100"},"正在更新系统",-1)),t("p",dt,x(v.value),1),t("div",mt,[t("div",{class:"h-3 rounded-full bg-blue-600 transition-all duration-300",style:_e({width:`${p.value}%`})},null,4)]),t("div",ut,"进度: "+x(p.value)+"%",1)])])])):$("",!0)]),_:1})]))}}),pt=Se(gt,[["__scopeId","data-v-803d9a07"]]);export{pt as default};
