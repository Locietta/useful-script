/**
 * rule preprocess script for clash-verge(-rev) and/or clash-party
 *
 * To use this parser, add a script configuration in subscription panel,
 * and copy this file to the script editor.
 */

/// config url-test
const test_interval = 150;
const test_tolerance = 250;
const fallback_test_interval = 30;
const test_url = "http://www.gstatic.com/generate_204";

/// ZJU RVPN
const rvpn_proxy = {
  name: "ZJU_RVPN_Socks5",
  type: "socks5",
  server: "127.0.0.1",
  port: "1080",
};

const rules = [
  /// custom rules
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
  "DOMAIN,dl.google.com,PROXY", // for golang install etc.

  /// ZJU sites
  "RULE-SET,zju,🚸 RVPN开关",
  "DOMAIN-SUFFIX,zju.edu.cn,🚸 RVPN开关",
  "DOMAIN-SUFFIX,cc98.org,🚸 RVPN开关",
  "RULE-SET,zju-rvpn,🚸 RVPN开关",

  /// general rules from trusted rule providers
  "RULE-SET,reject,🛑 广告拦截",
  "RULE-SET,icloud,DIRECT",
  "RULE-SET,apple,DIRECT",
  "RULE-SET,google,PROXY",
  "RULE-SET,tld-not-cn,PROXY",
  "RULE-SET,gfw,PROXY",
  "RULE-SET,greatfire,PROXY",
  "RULE-SET,direct,DIRECT",
  "RULE-SET,proxy,PROXY",
  "RULE-SET,private,DIRECT",

  /// IPCIDR Rules
  "IP-CIDR,10.0.0.0/8,🚸 RVPN开关",
  "IP-CIDR,58.196.192.0/19,🚸 RVPN开关",
  "IP-CIDR,58.196.224.0/20,🚸 RVPN开关",
  "IP-CIDR,58.200.100.0/24,🚸 RVPN开关",
  "IP-CIDR,210.32.0.0/20,🚸 RVPN开关",
  "IP-CIDR,210.32.128.0/19,🚸 RVPN开关",
  "IP-CIDR,210.32.160.0/21,🚸 RVPN开关",
  "IP-CIDR,210.32.168.0/22,🚸 RVPN开关",
  "IP-CIDR,210.32.172.0/23,🚸 RVPN开关",
  "IP-CIDR,210.32.174.0/24,🚸 RVPN开关",
  "IP-CIDR,210.32.176.0/20,🚸 RVPN开关",
  "IP-CIDR,222.205.0.0/17,🚸 RVPN开关",
  "RULE-SET,telegramcidr,PROXY",
  "RULE-SET,lancidr,DIRECT",
  "RULE-SET,cncidr,DIRECT",
  "GEOIP,CN,DIRECT",
  "MATCH,🔯 代理模式", // blackhole
];

/// extract special proxy group, so that we can directly use them later
/// otherwise, we need to find them in proxy_groups by querying their name...
const rvpn_selector = {
  name: "🚸 RVPN开关",
  type: "select",
  proxies: ["DIRECT", "ZJU_RVPN_Socks5"],
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
  interval: fallback_test_interval,
  hidden: true,
};

const proxy_groups = [
  {
    name: "🔯 代理模式",
    type: "select",
    proxies: ["绕过大陆丨黑名单(GFWlist)", "绕过大陆丨白名单(Whitelist)"],
  },
  rvpn_selector,
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
  zju: {
    type: "http",
    behavior: "classical",
    format: "text",
    interval: 86400,
    url: "https://raw.githubusercontent.com/SubConv/ZJU-Rule/main/Clash/ZJU.list",
    path: "./ruleset/zju_rule.txt",
  },
  "zju-rvpn": {
    type: "http",
    behavior: "classical",
    format: "text",
    interval: 86400,
    url: "https://raw.githubusercontent.com/SubConv/ZJU-Rule/refs/heads/main/Clash/ZJU-Rule.list",
    path: "./ruleset/zju_rvpn.txt",
  },
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
  return name.match(/刷新|机场\.com|25倍率|(T|t)raffic|(E|e)xpire|www\./);
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
  const proxy_provider_count =
    typeof config?.["proxy-providers"] === "object"
      ? Object.keys(config["proxy-providers"]).length
      : 0;
  if (proxy_count === 0 && proxy_provider_count === 0) {
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

  config.proxies.push(rvpn_proxy);

  if (proxy_provider_count > 0) {
    // make all proxy providers a separate proxy group
    provider_groups = [];

    for (const [provider_name, provider] of Object.entries(config["proxy-providers"])) {
      const group_name = `Provider: ${provider_name}`;
      provider_groups.push({
        name: group_name,
        use: [provider_name],
        type: "url-test",
        url: test_url,
        interval: test_interval,
        torlerance: test_tolerance,
        lazy: true,
        hidden: true,
      });
    }

    // inject them into manual selector
    manual_selector.proxies = manual_selector.proxies.concat(provider_groups.map((g) => g.name));
    proxy_groups.push(...provider_groups);
  }

  const parsed_config = {
    ...config,
    "proxy-groups": proxy_groups,
    rules: rules,
    "rule-providers": rule_providers,
    hosts: { ...config.hosts, ...hosts },
    dns: {
      ...config.dns,
      "nameserver-policy": {
        ...config.dns.nameserver_policy,
        "rule-set:zju": ["10.10.0.21", "10.10.2.21"],
        "+.zju6.edu.cn": ["10.10.0.21", "10.10.2.21"],
        // the dns in raw profile seems not working in newer version of clash-verge-rev/clash-party, because it's overriden by their DNS override feature
        // you may need to add `rule-set:zju=10.10.0.21;10.10.2.21, +.zju6.edu.cn=10.10.0.21;10.10.2.21` in the DNS override setting UI

        // NNOTE: for some reason clash-verge don't support rule-set:zju as the key currently (while the mihomo core does support it), but clash-party is fine with it
        // I'd suggest to use clash-party if possible, or you can copy the desired domains from the ruleset manually (e.g. '+.zju.edu.cn=10.10.0.21') to make it work in clash-verge
      },
    },
  };

  return parsed_config;
}
