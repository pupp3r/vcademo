using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using VCA_Contact_Demo.Extensions;
using VCA_Contact_Demo.Models;
using Newtonsoft.Json;

namespace VCA_Contact_Demo.Controllers
{
    public class ContactsController : BaseController
    {
        // GET: Contacts
        public ActionResult Index()
        {
            return View();
        }


        /// <summary>
        /// This is a JSON endpoint for the datatable in the page.
        /// It is requested once on page load, and then again after any subsequent CRUD operations
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public ActionResult GetContactListJson()
        {
            // get the user's contacts and add them to viewbag
            int webUserID = Convert.ToInt32(this.ClassicASP().WebUserID);
            List<contact> userContacts = GetContactsForWebUser(webUserID);
            return Json(userContacts, JsonRequestBehavior.AllowGet);
        }

        public List<contact> GetContactsForWebUser(int webUserID)
        {
            vcademoEntities db = new vcademoEntities();
            var contacts = db.contacts.Where(c => c.webuserid == webUserID);
            return contacts.ToList();
        }


        /// <summary>
        /// Endpoint for adding a contact. Gets the user's ID from the ASP session and then calls the DB method
        /// </summary>
        [HttpPost]
        public ActionResult AddContact(string firstName, string lastName, string email, string phone)
        {
            try
            {
                int webuserid = Convert.ToInt32(this.ClassicASP().WebUserID);
                AddContactToDB(webuserid, firstName, lastName, email, phone);
            } catch (Exception e)
            {
                return Json(new { success = false, error = e.Message });
            }

            return Json(new { success = true });
        }

        /// <summary>
        /// DB method for inserting a new contact
        /// </summary>
        /// <returns>The ID of the new contact in the table</returns>
        public contact AddContactToDB(int webUserID, string firstName, string lastName, string email, string phone)
        {
            vcademoEntities db = new vcademoEntities();
            contact c = new contact();
            c.webuserid = webUserID;
            c.created = DateTime.Now;
            c.firstname = firstName;
            c.lastname = lastName;
            c.email = email;
            c.phone = phone;
            db.contacts.Add(c);
            db.SaveChanges();
            return c;
        }

        /// <summary>
        /// Edits an existing contact in the DB
        /// </summary>
        [HttpPost]
        public ActionResult EditContact(int contactID, string firstName, string lastName, string email, string phone)
        {
            try
            {
                // validate that this record belongs to the currently logged in user
                int webUserID = Convert.ToInt32(this.ClassicASP().WebUserID);
                EditContactDB(contactID, webUserID, firstName, lastName, email, phone);

            } catch (Exception e)
            {
                return Json(new { success = false, error = e.Message });
            }

            return Json(new { success = true });
        }


        public contact EditContactDB(int contactID, int webUserID, string firstName, string lastName, string email, string phone)
        {
            vcademoEntities db = new vcademoEntities();
            contact c = db.contacts.Where(i => i.id == contactID).FirstOrDefault();

            if (c == null)
            {
                throw new Exception("Contact not found");
            }

            // validate that this record belongs to the currently logged in user
            if (c.webuserid != webUserID)
            {
                throw new Exception("You are not authorized to edit this contact");
            }

            // update the DB
            c.firstname = firstName;
            c.lastname = lastName;
            c.email = email;
            c.phone = phone;
            db.SaveChanges();
            return c;
        }


        /// <summary>
        /// Edits an existing contact in the DB
        /// </summary>
        [HttpPost]
        public ActionResult DeleteContact(int contactID)
        {
            try
            {
                vcademoEntities db = new vcademoEntities();
                contact c = db.contacts.Where(i => i.id == contactID).FirstOrDefault();

                // validate that this record belongs to the currently logged in user
                int webUserID = Convert.ToInt32(this.ClassicASP().WebUserID);
                DeleteContactDB(contactID, webUserID);

            } catch (Exception e)
            {
                return Json(new { success = false, error = e.Message });
            }

            return Json(new { success = true });
        }

        public void DeleteContactDB(int contactID, int webUserID)
        {
            vcademoEntities db = new vcademoEntities();
            contact c = db.contacts.Where(i => i.id == contactID).FirstOrDefault();

            if (c == null)
            {
                throw new Exception("Contact not found");
            }

            // validate that this record belongs to the currently logged in user
            if (c.webuserid != webUserID)
            {
                throw new Exception("You are not authorized to delete this contact");
            }

            db.contacts.Remove(c);
            db.SaveChanges();
        }
    }
}