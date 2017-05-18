using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;

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
    }
}