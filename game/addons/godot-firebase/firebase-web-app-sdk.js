// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAZN908qscSjki0Ij3D3tmU_XuwTCyLAks",
  authDomain: "komtur-95c6f.firebaseapp.com",
  projectId: "komtur-95c6f",
  storageBucket: "komtur-95c6f.appspot.com",
  messagingSenderId: "744288068093",
  appId: "1:744288068093:web:f22193d35b6a5e41ee7994",
  measurementId: "G-D46K7LKQB0"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
