using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;

namespace VCA_Contact_Demo.ClassicASP
{
    public enum SyncMode
    {
        ReadOnly,
        Merge,
        Replace,
        Clear,
        Abandon
    }

    public class SessionInfo
    {
        public SyncMode SaveMode { get; set; } = SyncMode.ReadOnly;
        public long? SessionId { get; set; }
        public Dictionary<string, object> Session { get; } = new Dictionary<string, object>(StringComparer.InvariantCultureIgnoreCase);

        [JsonExtensionData]
        public Dictionary<string, object> Extra { get; } = new Dictionary<string, object>(StringComparer.InvariantCultureIgnoreCase);

        //elevate the Session methods & accessors for convenience
        //NOTE: ipmlementing IDictionary<> or inheriting Dictionary<> breaks our serialization behavior, so if you need Linq methods use the child Session property
        public object this[string key]
        {
            get => Session.ContainsKey(key) ? ((IDictionary<string, object>)Session)[key] : null;
            set => ((IDictionary<string, object>)Session)[key] = value;
        }
        [JsonIgnore]
        public ICollection<string> Keys => Session.Keys;
        [JsonIgnore]
        public ICollection<object> Values => Session.Values;

        public int Count => Session.Count;
        public void Add(string key, object value) => Session.Add(key, value);
        public void Clear() => Session.Clear();
        public bool ContainsKey(string key) => Session.ContainsKey(key);
        public Dictionary<string, object>.Enumerator GetEnumerator() => Session.GetEnumerator();
        public bool Remove(string key) => Session.Remove(key);
        public bool TryGetValue(string key, out object value) => Session.TryGetValue(key, out value);

        //some helpers so I don't have to remember the key names
        public int? WebUserID => TryGetValue("webuserid", out var id) ? unchecked((int?)(long?)id) : null;
        public bool IsLoggedIn => this.ContainsKey("loggedin") && !string.IsNullOrEmpty((string)this["loggedin"]);
        public string MemberName => TryGetValue("member_name", out var name) ? (string)name : "";
        public string MemberEmail => TryGetValue("member_email", out var email) ? (string)email : "";
        public string MemberTitle => TryGetValue("member_title", out var title) ? (string)title : "";
        public string[] Roles => this.TryGetValue("assigned_roles", out var roles) ? ((JArray)roles).ToObject<string[]>().Select(s => s.ToLowerInvariant()).Append("any").ToArray() : Array.Empty<string>();
        public bool HasRole(string role) => this.Roles.Contains(role.ToLowerInvariant());
        public bool HasRoles(params string[] requiredRoles) => this.Roles.Intersect(requiredRoles.Select(r => r.ToLowerInvariant())).Any();
    }
}