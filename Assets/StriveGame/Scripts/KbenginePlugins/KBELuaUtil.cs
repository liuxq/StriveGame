using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;
using System.IO;
using LuaFramework;

namespace KBEngine
{
    public static class KBELuaUtil
    {
        public static byte[] Utf8ToByte(object utf8)
        {
            return System.Text.Encoding.UTF8.GetBytes((string)utf8);
        }

        public static string ByteToUtf8(byte[] bytes)
        {
            return System.Text.Encoding.UTF8.GetString(bytes);
        }

        public static void ArrayCopy(byte[] srcdatas, long srcLen, byte[] dstdatas, long dstLen, long len)
        {
            Array.Copy(srcdatas, srcLen, dstdatas, dstLen, len);
        }

        public static void Log(string str)
        {
            Debug.Log(str);
        }

        public static void LogWarning(string str)
        {
            Debug.LogWarning(str);
        }

        public static void LogError(string str)
        {
            Debug.LogError(str);
        }

        /// <summary>
        /// 执行Lua方法..
        /// </summary>
        public static object[] CallMethod(string module, string func, params object[] args)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (luaMgr == null) return null;
            return luaMgr.CallFunction(module + "." + func, args);
        }

        public static object[] CallMethod(string func, params object[] args)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (luaMgr == null) return null;
            return luaMgr.CallFunction(func, args);
        }

        public static void createFile(string path, string name, byte[] datas)
        {
            deleteFile(path, name);
            Dbg.DEBUG_MSG("createFile: " + path + "/" + name);
            FileStream fs = new FileStream(path + "/" + name, FileMode.OpenOrCreate, FileAccess.Write);
            fs.Write(datas, 0, datas.Length);
            fs.Close();
            fs.Dispose();
        }

        public static byte[] loadFile(string path, string name, bool printerr)
        {
            FileStream fs;

            try
            {
                fs = new FileStream(path + "/" + name, FileMode.Open, FileAccess.Read);
            }
            catch (Exception e)
            {
                if (printerr)
                {
                    Dbg.ERROR_MSG("loadFile: " + path + "/" + name);
                    Dbg.ERROR_MSG(e.ToString());
                }

                return new byte[0];
            }

            byte[] datas = new byte[fs.Length];
            fs.Read(datas, 0, datas.Length);
            fs.Close();
            fs.Dispose();

            Dbg.DEBUG_MSG("loadFile: " + path + "/" + name + ", datasize=" + datas.Length);
            return datas;
        }

        public static void deleteFile(string path, string name)
        {
            //Dbg.DEBUG_MSG("deleteFile: " + path + "/" + name);

            try
            {
                File.Delete(path + "/" + name);
            }
            catch (Exception e)
            {
                Debug.LogError(e.ToString());
            }
        }  

        public static string bytesToString(byte[] bytes)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            return encoding.GetString(bytes);
        }

        public static byte[] stringToBytes(string str)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            return encoding.GetBytes(str);
        }
    }
}