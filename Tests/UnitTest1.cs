using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using VCA_Contact_Demo.Controllers;
using VCA_Contact_Demo.Models;

namespace VCA_Contact_Demo.Tests
{
    [TestClass]
    public class UnitTest1
    {

        private int testWebUserID = 1;

        [TestMethod]
        public void TestAddContact()
        {
            // arrange
            var controller = new ContactsController();

            // act
            // test adding a contact to the DB
            var result = controller.AddContactToDB(testWebUserID, "test", "test", "test", "test");

            // assert
            Assert.AreEqual(result.GetType(), typeof(contact)); // must return a contact
            Assert.AreEqual(result.id.GetType(), typeof(int)); // contact must have an id
        }


        [TestMethod]
        public void TestReadContacts()
        {
            // arrange
            var controller = new ContactsController();

            // act
            // test adding a contact to the DB
            var result = controller.GetContactsForWebUser(testWebUserID);

            // assert
            Assert.AreEqual(result.GetType(), typeof(List<contact>)); // must return a contact list
        }


        [TestMethod]
        public void TestEditContact()
        {
            // arrange
            var controller = new ContactsController();

            // act
            List<contact> contactsList = controller.GetContactsForWebUser(testWebUserID);
            contact firstContact = contactsList.First();
            var result = controller.EditContactDB(firstContact.id, testWebUserID, "testedit", "test", "test", "test");

            // assert
            Assert.AreEqual(result.GetType(), typeof(contact)); // must return a contact list
        }


        [TestMethod]
        public void TestDeleteContact()
        {
            // arrange
            var controller = new ContactsController();

            // act
            // get the contact to delete
            List<contact> contactsList = controller.GetContactsForWebUser(testWebUserID);
            contact firstContact = contactsList.First();
            // test deletion
            controller.DeleteContactDB(firstContact.id, testWebUserID);

            // assert
            // as long as we get here, the test has succeeded (delete method returns void)
        }

    }
}
