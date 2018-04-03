﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Mayiboy.Admin.UI.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        [LoginAuth]
        public ActionResult Index()
        {
            return View();
        }
    }
}