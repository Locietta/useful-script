/**
 * rule preprocess script for clash-verge(-rev)
 *
 * To use this parser, add a script configuration in subscription panel,
 * and copy this file to the script editor.
 */

/// config url-test
const test_interval = 150;
const test_tolerance = 250;
const test_url = "http://www.gstatic.com/generate_204";

// Fxxk up EasyConnect
const easy_connect = {
  name: "EasyConnectSocks5",
  type: "socks5",
  server: "127.0.0.1",
  port: "1080",
};
const easy_connect_http = {
  name: "EasyConnectHttp",
  type: "http",
  server: "127.0.0.1",
  port: "1081",
};

const rules = [
  // custom rules
  "IP-CIDR,10.0.0.0/24,🚸 EasyConnect开关",
  "DOMAIN-SUFFIX,zju.edu.cn,🚸 EasyConnect开关",
  "DOMAIN-SUFFIX,cc98.org,🚸 EasyConnect开关",
  "DOMAIN-SUFFIX,cnki.net,🚸 EasyConnect开关",

  "RULE-SET,applications,DIRECT",
  "PROCESS-NAME,wireguard.exe,DIRECT",
  "PROCESS-NAME,wireguard,DIRECT",
  "DOMAIN-SUFFIX,z-lib.org,PROXY",
  "DOMAIN-SUFFIX,cppreference.com,PROXY",
  "DOMAIN-SUFFIX,bing.com,PROXY",
  "DOMAIN-SUFFIX,store.steampowered.com,PROXY",
  "DOMAIN-SUFFIX,steamcommunity.com,PROXY",
  "DOMAIN-SUFFIX,gamesauce.org,PROXY",
  "DOMAIN-SUFFIX,wolfram.com,PROXY",
  "DOMAIN-SUFFIX,wolframcdn.com,PROXY",
  "DOMAIN-SUFFIX,ieee.org,DIRECT",
  "DOMAIN-SUFFIX,acm.org,DIRECT",
  "DOMAIN-SUFFIX,stackoverflow.com,DIRECT",
  "DOMAIN-SUFFIX,stackexchange.com,DIRECT",
  "DOMAIN-SUFFIX,ppy.sh,DIRECT",
  "DOMAIN-SUFFIX,bog.ac,DIRECT",
  "DOMAIN-SUFFIX,nexushd.org,DIRECT",
  "DOMAIN,clash.razord.top,DIRECT",
  "DOMAIN,cn.bing.com,DIRECT",
  "DOMAIN,dl.google.com,PROXY", // for golang install etc.
  "DOMAIN-SUFFIX,edu.cn,DIRECT",

  // rules for rule providers
  "RULE-SET,private,DIRECT",
  "RULE-SET,reject,🛑 广告拦截",
  "RULE-SET,icloud,DIRECT",
  "RULE-SET,apple,DIRECT",
  "RULE-SET,google,PROXY",
  "RULE-SET,tld-not-cn,PROXY",
  "RULE-SET,gfw,PROXY",
  "RULE-SET,greatfire,PROXY",
  "RULE-SET,telegramcidr,PROXY",
  "RULE-SET,lancidr,DIRECT",
  "RULE-SET,cncidr,DIRECT",
  "GEOIP,,DIRECT",
  "GEOIP,CN,DIRECT",
  "RULE-SET,direct,DIRECT",
  "RULE-SET,proxy,PROXY",
  "MATCH,🔯 代理模式",
];

/// extract special proxy group, so that we can directly use them later
/// otherwise, we need to find them in proxy_groups by querying their name...
const easy_connect_group = {
  name: "🚸 EasyConnect开关",
  type: "select",
  proxies: ["DIRECT", "EasyConnectSocks5", "EasyConnectHttp"],
};
const core_proxy = {
  name: "PROXY",
  type: "select",
  proxies: ["🔰 手动选择", "🚀 自动节点", "🔧 故障转移"],
};
const manual_selector = {
  name: "🔰 手动选择",
  type: "select",
  proxies: ["DIRECT"],
};
const auto_selector = {
  name: "🚀 自动节点",
  type: "url-test",
  url: test_url,
  interval: test_interval,
  torlerance: test_tolerance,
  lazy: true,
  hidden: true,
};
const fallback_selector = {
  name: "🔧 故障转移",
  type: "fallback",
  url: test_url,
  interval: test_interval,
  hidden: true,
};

const proxy_groups = [
  {
    name: "🔯 代理模式",
    type: "select",
    proxies: ["绕过大陆丨黑名单(GFWlist)", "绕过大陆丨白名单(Whitelist)"],
  },
  easy_connect_group,
  core_proxy,
  manual_selector,
  auto_selector,
  fallback_selector,
  {
    name: "🛑 广告拦截",
    type: "select",
    proxies: ["DIRECT", "REJECT", "PROXY"],
  },
  {
    name: "绕过大陆丨黑名单(GFWlist)",
    type: "url-test",
    url: "http://www.gstatic.com/generate_204",
    interval: 86400,
    proxies: ["DIRECT"],
    hidden: true,
  },
  {
    name: "绕过大陆丨白名单(Whitelist)",
    type: "url-test",
    url: "http://www.gstatic.com/generate_204",
    interval: 86400,
    proxies: ["PROXY"],
    hidden: true,
  },
];

const rule_provider_default_opt = {
  type: "http",
  behavior: "domain",
  interval: 86400,
};

const rule_providers = {
  reject: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt",
    path: "./ruleset/reject.yaml",
  },
  icloud: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt",
    path: "./ruleset/icloud.yaml",
  },
  apple: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt",
    path: "./ruleset/apple.yaml",
  },
  google: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/google.txt",
    path: "./ruleset/google.yaml",
  },
  proxy: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt",
    path: "./ruleset/proxy.yaml",
  },
  direct: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt",
    path: "./ruleset/direct.yaml",
  },
  private: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt",
    path: "./ruleset/private.yaml",
  },
  gfw: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/gfw.txt",
    path: "./ruleset/gfw.yaml",
  },
  greatfire: {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/greatfire.txt",
    path: "./ruleset/greatfire.yaml",
  },
  "tld-not-cn": {
    ...rule_provider_default_opt,
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/tld-not-cn.txt",
    path: "./ruleset/tld-not-cn.yaml",
  },
  telegramcidr: {
    ...rule_provider_default_opt,
    behavior: "ipcidr",
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt",
    path: "./ruleset/telegramcidr.yaml",
  },
  cncidr: {
    ...rule_provider_default_opt,
    behavior: "ipcidr",
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt",
    path: "./ruleset/cncidr.yaml",
  },
  lancidr: {
    ...rule_provider_default_opt,
    behavior: "ipcidr",
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/lancidr.txt",
    path: "./ruleset/lancidr.yaml",
  },
  applications: {
    ...rule_provider_default_opt,
    behavior: "classical",
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/applications.txt",
    path: "./ruleset/applications.yaml",
  },
};

/// custom hosts
const hosts = {
  //"api.msn.com": "0.0.0.0",
  //"pipe.aria.microsoft.com": "0.0.0.0",
  // "ntp.msn.com": "0.0.0.0", // new tab
  //"web.vortex.data.microsoft.com": "0.0.0.0",
  //"browser.events.data.msn.com": "0.0.0.0",
  //"www.msn.com": "0.0.0.0",
  // "assets.msn.com": "0.0.0.0",
  //"c.msn.com": "0.0.0.0",
  // China-specific
  "api.msn.cn": "0.0.0.0",
  "pipe.aria.microsoft.cn": "0.0.0.0",
  "ntp.msn.cn": "0.0.0.0",
  "web.vortex.data.microsoft.cn": "0.0.0.0",
  "browser.events.data.msn.cn": "0.0.0.0",
  "www.msn.cn": "0.0.0.0",
  "assets.msn.cn": "0.0.0.0",
  "c.msn.cn": "0.0.0.0",
};

/** @param {string} name @returns {boolean} */
function proxy_excluder(name) {
  // exclude nodes you don't want, e.g. high multiplier / info-only nodes
  return name.match(/刷新|机场.com|25倍率|(T|t)raffic|(E|e)xpire/);
}

/// region matcher
const regions = [
  ["香港", /香港|HK|Hong Kong/, "🇭🇰"],
  ["台湾", /台湾|TW|(T|t)aiwan/, "🇹🇼"],
  ["日本", /日本|JP|(J|j)apan/, "🇯🇵"],
  ["韩国", /韩国|KR|(K|k)orea/, "🇰🇷"],
  ["新加坡", /新加坡|SG|Singapore/, "🇸🇬"],
  ["美国", /美国|US|United States|America/, "🇺🇸"],
  ["澳大利亚", /澳大利亚|AU|Australia/, "🇦🇺"],
  ["英国", /英国|GB|UK|United Kingdom/, "🇬🇧"],
  ["加拿大", /加拿大|(C|c)anada/, "🇨🇦"],
  ["德国", /德国|DE|(G|g)ermany/, "🇩🇪"],
  ["法国", /法国|FR|(F|f)rance/, "🇫🇷"],
];

function main(config) {
  const proxy_count = config?.proxies?.length ?? 0;
  const proxy_group_Count =
    typeof config?.["proxy-providers"] === "object"
      ? Object.keys(config["proxy-providers"]).length
      : 0;
  if (proxy_count === 0 && proxy_group_Count === 0) {
    throw new Error("No proxies or proxy groups found in the config.");
  }
  const proxy_names = config.proxies
    .filter((proxy) => !proxy_excluder(proxy.name))
    .map((proxy) => proxy.name);

  // inject proxies into default groups
  auto_selector.proxies = fallback_selector.proxies = proxy_names;
  manual_selector.proxies = manual_selector.proxies.concat(proxy_names);

  // detect region specific proxies
  for (const [region, pattern, flag_icon] of regions) {
    const proxies = proxy_names.filter((name) => name.match(pattern));
    if (proxies.length === 0) continue;

    const group_name = `${flag_icon} ${region}节点`;

    core_proxy.proxies.push(group_name);
    proxy_groups.push({
      name: group_name,
      type: "url-test",
      url: test_url,
      interval: test_interval,
      torlerance: test_tolerance,
      lazy: true,
      proxies: proxies,
      hidden: true,
    });
  }

  config.proxies.push(easy_connect);
  config.proxies.push(easy_connect_http);

  const parsed_config = {
    ...config,
    "proxy-groups": proxy_groups,
    rules: rules,
    "rule-providers": rule_providers,
    hosts: { ...config.hosts, ...hosts },
  };

  return parsed_config;
}
