﻿using System;
using System.Collections;
using System.Reflection;
using Framework.Mayiboy.Utility;
using Mayiboy.ConstDefine;
using Mayiboy.Model.Model;
using Mayiboy.Utils;

namespace Mayiboy.Logic
{
    /// <summary>
    /// 实体默认值处理
    /// </summary>
    public class EntityLogger
    {
        /// <summary>
        /// 修改创建实体默认属性（CrateUserId、CreateTime、IsValid）
        /// </summary>
        /// <param name="entity"></param>
        public static void CreateEntity(object entity)
        {
            var properties = entity.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance);

            foreach (var prop in properties)
            {
                switch (prop.Name.ToLower())
                {
                    case "updateuserid":
                    case "createuserid":
                        prop.SetValue(entity, LoginUserId);
                        break;
                    case "updatetime":
                    case "createtime":
                        prop.SetValue(entity, DateTime.Now);
                        break;
                    case "isvalid":
                        prop.SetValue(entity, 1);
                        break;
                }
            }
        }

        /// <summary>
        /// 修改创建实体内嵌实体默认属性（CrateUserId、CreateTime、IsValid）
        /// </summary>
        /// <param name="entity"></param>
        public static void CreateEntityNested(object entity)
        {
            CreateEntity(entity);

            var properties = entity.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (var prop in properties)
            {
                if (prop.PropertyType.Name != "String" && prop.PropertyType.GetInterface("IEnumerable", false) != null)
                {
                    var collection = prop.GetValue(entity) as IEnumerable;
                    if (collection != null)
                    {
                        foreach (var item in collection)
                        {
                            CreateEntityNested(item);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 修改更新实体默认属性（UpateUserId、UpdateTime）
        /// </summary>
        /// <param name="entity"></param>
        public static void UpdateEntity(object entity)
        {
            var properties = entity.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (var prop in properties)
            {
                switch (prop.Name.ToLower())
                {
                    case "updateuserid":
                        prop.SetValue(entity, LoginUserId);
                        break;
                    case "updatetime":
                        prop.SetValue(entity, DateTime.Now);
                        break;
                }
            }
        }

        /// <summary>
        /// 修改更新实体内嵌实体默认属性（UpateUserId、UpdateTime）
        /// </summary>
        /// <param name="entity"></param>
        public static void UpdateEntityNested(object entity)
        {
            UpdateEntity(entity);

            var properties = entity.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance);

            foreach (var prop in properties)
            {
                if (prop.PropertyType.Name != "String" && prop.PropertyType.GetInterface("IEnumerable", false) != null)
                {
                    var collection = prop.GetValue(entity) as IEnumerable;

                    if (collection != null)
                    {
                        foreach (var item in collection)
                        {
                            UpdateEntityNested(item);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 登录用户Id
        /// </summary>
        private static int LoginUserId
        {
            get
            {
                var identityvalue = CookieHelper.Get(PublicConst.IdentityCookieKey);

                if (identityvalue.IsNullOrEmpty())
                {
                    return 0;
                }

                var cachekey = identityvalue.AddCachePrefix(PublicConst.IdentityCookieKey);

                var entity = CacheManager.Get<AccountModel>(cachekey, 2);

                if (entity == null)
                {
                    return 0;
                }

                return entity.Id;
            }
        }
    }
}