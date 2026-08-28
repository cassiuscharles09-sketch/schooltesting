/**
 * DATAMEXT COLLEGE OF ST. ADELINE (DCSA)
 * Portal Engine & Real-Time Cloud Data Management System
 * Integrated with: Supabase Cloud Database + Offline LocalStorage Cache
 * Handles: Real-Time Cloud Sync, Multi-device Data Persistence, Authentication, CRUD, Analytics, and Student Portal
 */

const DCSA_STORAGE_KEYS = {
  APPLICANTS: 'dcsa_applicants_data',
  ADMIN_SESSION: 'dcsa_admin_session',
  STUDENT_SESSION: 'dcsa_student_session',
  ANNOUNCEMENTS: 'dcsa_announcements_data'
};

// Supabase Cloud Configuration
const SUPABASE_CONFIG = {
  url: "https://gnlwinnbviygczdaugkr.supabase.co",
  anonKey: "sb_publishable_hBvdHeeQdVolgS1yM9XrbA__va6cwcy"
};

let _supabase = null;
function getSupabaseClient() {
  if (!_supabase && typeof window !== 'undefined' && window.supabase && window.supabase.createClient) {
    try {
      _supabase = window.supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
    } catch (e) {
      console.warn("Supabase init warning:", e);
    }
  }
  return _supabase;
}

// Auto-inject Supabase CDN if not yet loaded in HTML
(function ensureSupabaseScript() {
  if (typeof window !== 'undefined' && !window.supabase && !document.getElementById('supabase-cdn-script')) {
    const s = document.createElement('script');
    s.id = 'supabase-cdn-script';
    s.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
    s.onload = function() {
      if (typeof DCSA_DB !== 'undefined' && DCSA_DB.syncFromSupabase) {
        DCSA_DB.syncFromSupabase();
      }
    };
    document.head.appendChild(s);
  }
})();

// Default Sample / Seed Data
const SEED_APPLICANTS = [
  {
    id: "DCSA-2026-0101",
    firstName: "Juan",
    middleName: "Protacio",
    lastName: "Dela Cruz",
    suffix: "",
    gender: "Male",
    birthDate: "2007-06-19",
    age: 18,
    civilStatus: "Single",
    email: "juan.delacruz@example.com",
    contactNo: "09171234567",
    address: "Block 4 Lot 12, Commonwealth Ave., Quezon City",
    guardianName: "Maria Dela Cruz",
    guardianContact: "09187654321",
    guardianRelation: "Mother",
    level: "College",
    program: "BSIT - Bachelor of Science in Information Technology",
    branch: "Fairview",
    entryType: "Freshman",
    lastSchool: "Commonwealth High School",
    voucherBeneficiary: "No",
    status: "Approved",
    dateApplied: "2026-08-15 09:30 AM",
    notes: "Submitted Form 138 and PSA Birth Certificate.",
    studentId: "DCSA-2026-IT-0042"
  },
  {
    id: "DCSA-2026-0102",
    firstName: "Maria Clara",
    middleName: "Santos",
    lastName: "Reyes",
    suffix: "",
    gender: "Female",
    birthDate: "2008-03-12",
    age: 17,
    civilStatus: "Single",
    email: "maria.reyes@example.com",
    contactNo: "09289876543",
    address: "10th Ave. cor J. Teodoro St., Caloocan City",
    guardianName: "Pedro Reyes",
    guardianContact: "09201122334",
    guardianRelation: "Father",
    level: "SHS",
    program: "TVL-ICT - Information and Communications Technology",
    branch: "Caloocan",
    entryType: "Freshman",
    lastSchool: "Caloocan National High School",
    voucherBeneficiary: "Yes",
    status: "Enrolled",
    dateApplied: "2026-08-16 02:15 PM",
    notes: "100% DepEd Voucher Recipient. Fully verified.",
    studentId: "DCSA-2026-SHS-0118"
  },
  {
    id: "DCSA-2026-0103",
    firstName: "Joshua",
    middleName: "Alvarez",
    lastName: "Tan",
    suffix: "Jr.",
    gender: "Male",
    birthDate: "2006-11-05",
    age: 19,
    civilStatus: "Single",
    email: "joshua.tan@example.com",
    contactNo: "09395551234",
    address: "MacArthur Highway, Marulas, Valenzuela City",
    guardianName: "Elena Tan",
    guardianContact: "09395559876",
    guardianRelation: "Mother",
    level: "College",
    program: "BSHM - Bachelor of Science in Hospitality Management",
    branch: "Valenzuela",
    entryType: "Transferee",
    lastSchool: "Valenzuela Polytechnic College",
    voucherBeneficiary: "No",
    status: "Pending",
    dateApplied: "2026-08-17 11:45 AM",
    notes: "Awaiting Honorable Dismissal and Good Moral.",
    studentId: ""
  },
  {
    id: "DCSA-2026-0104",
    firstName: "Princess Joy",
    middleName: "Mendoza",
    lastName: "Bautista",
    suffix: "",
    gender: "Female",
    birthDate: "2008-08-20",
    age: 17,
    civilStatus: "Single",
    email: "pj.bautista@example.com",
    contactNo: "09456789012",
    address: "Saluysoy, Meycauayan, Bulacan",
    guardianName: "Roberto Bautista",
    guardianContact: "09456781122",
    guardianRelation: "Father",
    level: "SHS",
    program: "ABM - Accountancy, Business, and Management",
    branch: "Meycauayan",
    entryType: "Freshman",
    lastSchool: "Meycauayan Integrated High School",
    voucherBeneficiary: "Yes",
    status: "Pending",
    dateApplied: "2026-08-18 10:10 AM",
    notes: "Submitted ESC / Voucher Certificate.",
    studentId: ""
  }
];

const SEED_ANNOUNCEMENTS = [
  {
    id: 1,
    title: "Official Start of Classes for 1st Semester A.Y. 2026-2027",
    date: "August 2026",
    branch: "All Campuses",
    content: "Formal orientation and class start will begin on September 1, 2026. All officially enrolled students are advised to wear white polo/blouse during the first 2 weeks.",
    priority: "High"
  },
  {
    id: 2,
    title: "DepEd SHS Voucher Program Verification",
    date: "August 2026",
    branch: "All Campuses",
    content: "For Grade 11 entrants: Please submit a printed copy of your DepEd QVR Certificate or ESC Certificate to the Admissions Registrar to finalize 100% Free Tuition.",
    priority: "Medium"
  },
  {
    id: 3,
    title: "Uniform & Student ID Card Claiming Schedule",
    date: "August 2026",
    branch: "Fairview, Caloocan, Valenzuela, Meycauayan",
    content: "Student IDs and school uniforms can be claimed at the Registrar & Logistics Office from Monday to Friday, 8:00 AM to 5:00 PM.",
    priority: "Normal"
  }
];

// Official Admin Accounts Configuration
const DCSA_ADMIN_ACCOUNTS = [
  {
    username: "admin",
    password: "password123",
    name: "Head Registrar (Central Admin)",
    role: "SuperAdmin",
    branch: "All",
    description: "Main System Super Administrator - Full Access to all 4 campuses"
  },
  {
    username: "superadmin",
    password: "password123",
    name: "Central School Administrator",
    role: "SuperAdmin",
    branch: "All",
    description: "Main System Super Administrator - Full Access to all 4 campuses"
  },
  {
    username: "campusadminval",
    password: "password123",
    name: "Valenzuela Campus Registrar",
    role: "BranchAdmin",
    branch: "Valenzuela",
    description: "Valenzuela Branch Admissions Admin"
  },
  {
    username: "campusadmincal",
    password: "password123",
    name: "Caloocan Campus Registrar",
    role: "BranchAdmin",
    branch: "Caloocan",
    description: "Caloocan Branch Admissions Admin"
  },
  {
    username: "campusadminmeyc",
    password: "password123",
    name: "Meycauayan Campus Registrar",
    role: "BranchAdmin",
    branch: "Meycauayan",
    description: "Meycauayan Branch Admissions Admin"
  },
  {
    username: "campusadminfair",
    password: "password123",
    name: "Fairview Campus Registrar",
    role: "BranchAdmin",
    branch: "Fairview",
    description: "Fairview Branch Admissions Admin"
  }
];

// Course curriculum & subjects map
const COURSE_CURRICULUM = {
  "BSIT - Bachelor of Science in Information Technology": [
    { code: "IT101", desc: "Introduction to Computing & Logic Formulation", units: 3, time: "MWF 8:00 AM - 9:30 AM", room: "Comp Lab 1", instructor: "Prof. R. Mendoza" },
    { code: "IT102", desc: "Computer Programming 1 (Python & Web)", units: 3, time: "TTH 9:00 AM - 11:00 AM", room: "Comp Lab 2", instructor: "Engr. A. Cruz" },
    { code: "GE101", desc: "Understanding the Self", units: 3, time: "MWF 10:00 AM - 11:00 AM", room: "Room 204", instructor: "Prof. M. Santos" },
    { code: "GE102", desc: "Purposive Communication", units: 3, time: "MWF 1:00 PM - 2:00 PM", room: "Room 205", instructor: "Prof. L. Diaz" },
    { code: "IT103", desc: "Discrete Mathematics for IT", units: 3, time: "TTH 1:00 PM - 2:30 PM", room: "Room 301", instructor: "Prof. K. Soriano" },
    { code: "NSTP1", desc: "National Service Training Program 1", units: 3, time: "SAT 8:00 AM - 11:00 AM", room: "Gymnasium", instructor: "Col. V. Ramos" },
    { code: "PE101", desc: "Physical Fitness & Gymnastics", units: 2, time: "SAT 1:00 PM - 3:00 PM", room: "Quadrangle", instructor: "Coach J. Garcia" }
  ],
  "BSHM - Bachelor of Science in Hospitality Management": [
    { code: "HM101", desc: "Introduction to Hospitality Management", units: 3, time: "MWF 8:30 AM - 10:00 AM", room: "HM Lab 1", instructor: "Chef E. Gonzales" },
    { code: "HM102", desc: "Kitchen Essentials & Basic Food Preparation", units: 3, time: "TTH 8:00 AM - 11:00 AM", room: "Culinary Lab", instructor: "Chef D. Ramos" },
    { code: "GE101", desc: "Understanding the Self", units: 3, time: "MWF 10:00 AM - 11:00 AM", room: "Room 204", instructor: "Prof. M. Santos" },
    { code: "GE102", desc: "Purposive Communication", units: 3, time: "MWF 1:00 PM - 2:00 PM", room: "Room 205", instructor: "Prof. L. Diaz" },
    { code: "HM103", desc: "Sanitation, Safety & Hygiene", units: 3, time: "TTH 1:00 PM - 2:30 PM", room: "Room 302", instructor: "Prof. J. Aquino" },
    { code: "NSTP1", desc: "National Service Training Program 1", units: 3, time: "SAT 8:00 AM - 11:00 AM", room: "Gymnasium", instructor: "Col. V. Ramos" },
    { code: "PE101", desc: "Physical Fitness & Wellness", units: 2, time: "SAT 1:00 PM - 3:00 PM", room: "Quadrangle", instructor: "Coach J. Garcia" }
  ],
  "BSBA - Bachelor of Science in Business Administration": [
    { code: "BA101", desc: "Basic Microeconomics", units: 3, time: "MWF 8:00 AM - 9:30 AM", room: "Room 101", instructor: "Prof. G. Tolentino" },
    { code: "BA102", desc: "Principles of Management", units: 3, time: "TTH 9:00 AM - 10:30 AM", room: "Room 102", instructor: "Prof. C. Rivera" },
    { code: "BA103", desc: "Financial Accounting 1", units: 3, time: "MWF 10:00 AM - 11:30 AM", room: "Room 103", instructor: "CPA N. Perez" },
    { code: "GE101", desc: "Understanding the Self", units: 3, time: "MWF 1:00 PM - 2:00 PM", room: "Room 204", instructor: "Prof. M. Santos" },
    { code: "GE102", desc: "Purposive Communication", units: 3, time: "TTH 1:00 PM - 2:30 PM", room: "Room 205", instructor: "Prof. L. Diaz" },
    { code: "NSTP1", desc: "National Service Training Program 1", units: 3, time: "SAT 8:00 AM - 11:00 AM", room: "Gymnasium", instructor: "Col. V. Ramos" },
    { code: "PE101", desc: "Physical Fitness & Wellness", units: 2, time: "SAT 1:00 PM - 3:00 PM", room: "Quadrangle", instructor: "Coach J. Garcia" }
  ],
  "TVL-ICT - Information and Communications Technology": [
    { code: "ICT-G11-01", desc: "Computer Systems Servicing (CSS NC II)", units: 4, time: "MWF 7:30 AM - 9:30 AM", room: "ICT Lab 1", instructor: "Sir A. Reyes" },
    { code: "ICT-G11-02", desc: "Oral Communication in Context", units: 3, time: "MWF 9:45 AM - 11:00 AM", room: "Room SHS-1", instructor: "Ms. H. Valenzuela" },
    { code: "ICT-G11-03", desc: "Komunikasyon at Pananaliksik sa Wika", units: 3, time: "MWF 1:00 PM - 2:15 PM", room: "Room SHS-1", instructor: "G. F. Castillo" },
    { code: "ICT-G11-04", desc: "General Mathematics", units: 3, time: "TTH 8:00 AM - 9:45 AM", room: "Room SHS-1", instructor: "Engr. P. Navarro" },
    { code: "ICT-G11-05", desc: "Earth and Life Science", units: 3, time: "TTH 10:00 AM - 11:45 AM", room: "Sci Lab", instructor: "Ms. T. Domingo" },
    { code: "ICT-G11-06", desc: "21st Century Literature from PH & World", units: 3, time: "TTH 1:00 PM - 2:30 PM", room: "Room SHS-1", instructor: "Ms. C. David" },
    { code: "PE-G11-01", desc: "Physical Education and Health 1", units: 2, time: "FRI 2:30 PM - 4:30 PM", room: "Quadrangle", instructor: "Sir B. Ocampo" }
  ],
  "ABM - Accountancy, Business, and Management": [
    { code: "ABM-G11-01", desc: "Fundamentals of Accountancy, Business & Mgmt 1", units: 4, time: "MWF 7:30 AM - 9:30 AM", room: "Room SHS-2", instructor: "CPA D. Villanueva" },
    { code: "ABM-G11-02", desc: "Oral Communication in Context", units: 3, time: "MWF 9:45 AM - 11:00 AM", room: "Room SHS-2", instructor: "Ms. H. Valenzuela" },
    { code: "ABM-G11-03", desc: "Komunikasyon at Pananaliksik sa Wika", units: 3, time: "MWF 1:00 PM - 2:15 PM", room: "Room SHS-2", instructor: "G. F. Castillo" },
    { code: "ABM-G11-04", desc: "General Mathematics", units: 3, time: "TTH 8:00 AM - 9:45 AM", room: "Room SHS-2", instructor: "Engr. P. Navarro" },
    { code: "ABM-G11-05", desc: "Business Math", units: 3, time: "TTH 10:00 AM - 11:45 AM", room: "Room SHS-2", instructor: "Prof. S. Lopez" },
    { code: "PE-G11-01", desc: "Physical Education and Health 1", units: 2, time: "FRI 2:30 PM - 4:30 PM", room: "Quadrangle", instructor: "Sir B. Ocampo" }
  ]
};

// Fallback subjects for other strands (STEM, HUMSS, GAS, etc.)
const DEFAULT_SUBJECTS = [
  { code: "CORE-101", desc: "Oral Communication in Context", units: 3, time: "MWF 8:00 AM - 9:30 AM", room: "Room 105", instructor: "Faculty Staff" },
  { code: "CORE-102", desc: "Komunikasyon at Pananaliksik sa Wika", units: 3, time: "MWF 9:45 AM - 11:15 AM", room: "Room 105", instructor: "Faculty Staff" },
  { code: "CORE-103", desc: "General Mathematics", units: 3, time: "TTH 8:30 AM - 10:00 AM", room: "Room 105", instructor: "Faculty Staff" },
  { code: "CORE-104", desc: "Earth and Life Science", units: 3, time: "TTH 10:15 AM - 11:45 AM", room: "Sci Lab", instructor: "Faculty Staff" },
  { code: "CORE-105", desc: "Understanding Culture, Society & Politics", units: 3, time: "MWF 1:00 PM - 2:30 PM", room: "Room 105", instructor: "Faculty Staff" },
  { code: "PE-101", desc: "Physical Education & Health 1", units: 2, time: "FRI 2:30 PM - 4:30 PM", room: "Quadrangle", instructor: "Sports Coordinator" }
];

// Helper to convert Supabase row (snake_case) to Frontend model (camelCase)
function mapSupabaseRowToApplicant(row) {
  return {
    id: row.id,
    firstName: row.first_name || "",
    middleName: row.middle_name || "",
    lastName: row.last_name || "",
    suffix: row.suffix || "",
    gender: row.gender || "Not Specified",
    birthDate: row.birth_date || "",
    age: row.age || 0,
    civilStatus: row.civil_status || "Single",
    email: row.email || "",
    contactNo: row.contact_no || "",
    address: row.address || "",
    guardianName: row.guardian_name || "",
    guardianContact: row.guardian_contact || "",
    guardianRelation: row.guardian_relation || "Parent/Guardian",
    level: row.level || "College",
    program: row.program || "",
    branch: row.branch || "Fairview",
    entryType: row.entry_type || "Freshman",
    lastSchool: row.last_school || "",
    voucherBeneficiary: row.voucher_beneficiary || "No",
    status: row.status || "Pending",
    dateApplied: row.date_applied || (row.created_at ? new Date(row.created_at).toLocaleString() : ""),
    notes: row.notes || "",
    studentId: row.student_id || ""
  };
}

// Initialize Real-time Data Store
const DCSA_DB = {
  init() {
    if (!localStorage.getItem(DCSA_STORAGE_KEYS.APPLICANTS)) {
      localStorage.setItem(DCSA_STORAGE_KEYS.APPLICANTS, JSON.stringify(SEED_APPLICANTS));
    }
    if (!localStorage.getItem(DCSA_STORAGE_KEYS.ANNOUNCEMENTS)) {
      localStorage.setItem(DCSA_STORAGE_KEYS.ANNOUNCEMENTS, JSON.stringify(SEED_ANNOUNCEMENTS));
    }
    // Background cloud sync
    this.syncFromSupabase();
  },

  // Real-time Cloud Sync from Supabase
  async syncFromSupabase() {
    const client = getSupabaseClient();
    if (!client) return;

    try {
      const { data, error } = await client
        .from('applicants')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.warn("Supabase fetch notice:", error.message);
        return;
      }

      if (data && data.length > 0) {
        const cloudApplicants = data.map(mapSupabaseRowToApplicant);
        // Merge with local seed if needed
        this.saveApplicants(cloudApplicants);
        // Trigger event so any active dashboard automatically re-renders
        if (typeof window !== 'undefined') {
          window.dispatchEvent(new CustomEvent('dcsa_data_synced', { detail: cloudApplicants }));
        }
      }
    } catch (e) {
      console.warn("Supabase sync failed (offline fallback active):", e);
    }
  },

  getApplicants() {
    this.init();
    try {
      return JSON.parse(localStorage.getItem(DCSA_STORAGE_KEYS.APPLICANTS)) || [];
    } catch (e) {
      return [];
    }
  },

  saveApplicants(list) {
    localStorage.setItem(DCSA_STORAGE_KEYS.APPLICANTS, JSON.stringify(list));
  },

  getApplicantById(idOrRef) {
    const list = this.getApplicants();
    const query = String(idOrRef).trim().toLowerCase();
    return list.find(a => 
      (a.id && a.id.toLowerCase() === query) || 
      (a.studentId && a.studentId.toLowerCase() === query) ||
      (a.email && a.email.toLowerCase() === query)
    );
  },

  async addApplicant(data) {
    const list = this.getApplicants();
    const year = new Date().getFullYear();
    const randomNum = Math.floor(1000 + Math.random() * 9000);
    const newId = `DCSA-${year}-${randomNum}`;
    const dateAppliedStr = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    
    const newEntry = {
      id: newId,
      firstName: data.firstName || "",
      middleName: data.middleName || "",
      lastName: data.lastName || "",
      suffix: data.suffix || "",
      gender: data.gender || "Not Specified",
      birthDate: data.birthDate || "",
      age: parseInt(data.age) || 0,
      civilStatus: data.civilStatus || "Single",
      email: data.email || "",
      contactNo: data.contactNo || "",
      address: data.address || "",
      guardianName: data.guardianName || "",
      guardianContact: data.guardianContact || "",
      guardianRelation: data.guardianRelation || "Parent/Guardian",
      level: data.level || "College",
      program: data.program || "BSIT - Bachelor of Science in Information Technology",
      branch: data.branch || "Fairview",
      entryType: data.entryType || "Freshman",
      lastSchool: data.lastSchool || "",
      voucherBeneficiary: data.voucherBeneficiary || "No",
      status: "Pending",
      dateApplied: dateAppliedStr,
      notes: data.notes || "Online Registration submission",
      studentId: ""
    };

    // Save locally immediately for 0ms UI delay
    list.unshift(newEntry);
    this.saveApplicants(list);

    // Save to Supabase Cloud Database asynchronously
    const client = getSupabaseClient();
    if (client) {
      client.from('applicants').insert([{
        id: newEntry.id,
        first_name: newEntry.firstName,
        middle_name: newEntry.middleName,
        last_name: newEntry.lastName,
        suffix: newEntry.suffix,
        gender: newEntry.gender,
        birth_date: newEntry.birthDate,
        age: newEntry.age,
        civil_status: newEntry.civilStatus,
        email: newEntry.email,
        contact_no: newEntry.contactNo,
        address: newEntry.address,
        guardian_name: newEntry.guardianName,
        guardian_contact: newEntry.guardianContact,
        guardian_relation: newEntry.guardianRelation,
        level: newEntry.level,
        program: newEntry.program,
        branch: newEntry.branch,
        entry_type: newEntry.entryType,
        last_school: newEntry.lastSchool,
        voucher_beneficiary: newEntry.voucherBeneficiary,
        status: newEntry.status,
        date_applied: newEntry.dateApplied,
        notes: newEntry.notes,
        student_id: newEntry.studentId
      }]).then(({ error }) => {
        if (error) {
          console.warn("Supabase insert notice:", error.message);
        } else {
          console.log("Record synced to Supabase Cloud successfully!");
        }
      }).catch(err => console.warn("Supabase network notice:", err));
    }

    return newEntry;
  },

  async updateApplicantStatus(id, newStatus, customNotes = "") {
    const list = this.getApplicants();
    const idx = list.findIndex(a => a.id === id);
    if (idx !== -1) {
      list[idx].status = newStatus;
      if (customNotes) {
        list[idx].notes = customNotes;
      }
      if (newStatus === "Enrolled" && !list[idx].studentId) {
        const progTag = list[idx].level === "SHS" ? "SHS" : "COL";
        const randomDigits = Math.floor(1000 + Math.random() * 9000);
        list[idx].studentId = `DCSA-2026-${progTag}-${randomDigits}`;
      }
      this.saveApplicants(list);

      // Cloud update in Supabase
      const client = getSupabaseClient();
      if (client) {
        const updatePayload = {
          status: list[idx].status,
          notes: list[idx].notes,
          student_id: list[idx].studentId
        };
        client.from('applicants')
          .update(updatePayload)
          .eq('id', id)
          .then(({ error }) => {
            if (error) console.warn("Supabase update error:", error.message);
          })
          .catch(err => console.warn("Supabase update network error:", err));
      }

      return list[idx];
    }
    return null;
  },

  async deleteApplicant(id) {
    let list = this.getApplicants();
    list = list.filter(a => a.id !== id);
    this.saveApplicants(list);

    // Cloud delete in Supabase
    const client = getSupabaseClient();
    if (client) {
      client.from('applicants')
        .delete()
        .eq('id', id)
        .then(({ error }) => {
          if (error) console.warn("Supabase delete error:", error.message);
        })
        .catch(err => console.warn("Supabase delete network error:", err));
    }
    return true;
  },

  getAnnouncements() {
    this.init();
    try {
      return JSON.parse(localStorage.getItem(DCSA_STORAGE_KEYS.ANNOUNCEMENTS)) || [];
    } catch (e) {
      return [];
    }
  },

  addAnnouncement(title, content, branch = "All Campuses", priority = "Normal") {
    const list = this.getAnnouncements();
    const newAnn = {
      id: Date.now(),
      title,
      content,
      branch,
      priority,
      date: new Date().toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
    };
    list.unshift(newAnn);
    localStorage.setItem(DCSA_STORAGE_KEYS.ANNOUNCEMENTS, JSON.stringify(list));
    return newAnn;
  },

  getSubjectsForProgram(programName) {
    if (COURSE_CURRICULUM[programName]) {
      return COURSE_CURRICULUM[programName];
    }
    for (const key in COURSE_CURRICULUM) {
      if (programName && (programName.includes(key) || key.includes(programName))) {
        return COURSE_CURRICULUM[key];
      }
    }
    return DEFAULT_SUBJECTS;
  },

  // Auth Helpers
  adminLogin(username, password) {
    const u = String(username).trim().toLowerCase();
    const acc = DCSA_ADMIN_ACCOUNTS.find(a => a.username.toLowerCase() === u && a.password === password);
    
    if (acc) {
      const session = {
        role: acc.role,
        username: acc.username,
        name: acc.name,
        branch: acc.branch,
        description: acc.description,
        loginTime: new Date().toISOString()
      };
      localStorage.setItem(DCSA_STORAGE_KEYS.ADMIN_SESSION, JSON.stringify(session));
      return { success: true, session };
    }
    return { 
      success: false, 
      message: "Maling Username o Password. Pakisuri ang iyong credentials." 
    };
  },

  getAdminSession() {
    try {
      return JSON.parse(localStorage.getItem(DCSA_STORAGE_KEYS.ADMIN_SESSION));
    } catch (e) {
      return null;
    }
  },

  adminLogout() {
    localStorage.removeItem(DCSA_STORAGE_KEYS.ADMIN_SESSION);
    localStorage.removeItem('dcsa_admin_session');
    sessionStorage.removeItem(DCSA_STORAGE_KEYS.ADMIN_SESSION);
    sessionStorage.removeItem('dcsa_admin_session');
  },

  async studentLogin(referenceOrId, lastName) {
    this.init();
    const queryRef = String(referenceOrId).trim().toLowerCase();
    const queryLast = String(lastName).trim().toLowerCase();

    // 1. Try local list first
    let list = this.getApplicants();
    let student = list.find(a => {
      const matchId = (a.id && a.id.toLowerCase() === queryRef) || 
                      (a.studentId && a.studentId.toLowerCase() === queryRef) ||
                      (a.email && a.email.toLowerCase() === queryRef);
      const matchLast = a.lastName && a.lastName.toLowerCase() === queryLast;
      return matchId && matchLast;
    });

    // 2. If not found locally, query Supabase directly
    if (!student) {
      const client = getSupabaseClient();
      if (client) {
        try {
          const { data, error } = await client
            .from('applicants')
            .select('*')
            .ilike('last_name', queryLast);

          if (!error && data && data.length > 0) {
            const foundRow = data.find(r => 
              (r.id && r.id.toLowerCase() === queryRef) ||
              (r.student_id && r.student_id.toLowerCase() === queryRef) ||
              (r.email && r.email.toLowerCase() === queryRef)
            );
            if (foundRow) {
              student = mapSupabaseRowToApplicant(foundRow);
              // Cache into local list
              list.unshift(student);
              this.saveApplicants(list);
            }
          }
        } catch (e) {
          console.warn("Supabase student login lookup warning:", e);
        }
      }
    }

    if (student) {
      localStorage.setItem(DCSA_STORAGE_KEYS.STUDENT_SESSION, JSON.stringify(student));
      return { success: true, student };
    }
    return { 
      success: false, 
      message: "Walang tugmang record na nahanap. Pakisuri ang Reference Number / Student ID at Apelyido." 
    };
  },

  getStudentSession() {
    try {
      const saved = JSON.parse(localStorage.getItem(DCSA_STORAGE_KEYS.STUDENT_SESSION));
      if (saved && saved.id) {
        const live = this.getApplicantById(saved.id);
        return live || saved;
      }
      return null;
    } catch (e) {
      return null;
    }
  },

  studentLogout() {
    localStorage.removeItem(DCSA_STORAGE_KEYS.STUDENT_SESSION);
  },

  // Export to CSV (with optional branch filter)
  exportApplicantsToCSV(branchFilter = "ALL") {
    let list = this.getApplicants();
    
    if (branchFilter && branchFilter !== "ALL") {
      list = list.filter(a => a.branch === branchFilter);
    }

    if (!list.length) {
      alert(`Walang applicant records na makikita para i-export (${branchFilter}).`);
      return;
    }

    const headers = [
      "Reference No", "Student ID", "Full Name", "Gender", "Birth Date", "Age",
      "Email", "Contact No", "Address", "Level", "Program / Strand", "Campus Branch",
      "Entry Type", "Voucher Beneficiary", "Date Applied", "Status", "Notes"
    ];

    const rows = list.map(a => [
      `"${a.id || ''}"`,
      `"${a.studentId || ''}"`,
      `"${a.lastName}, ${a.firstName} ${a.middleName || ''} ${a.suffix || ''}".trim()`,
      `"${a.gender || ''}"`,
      `"${a.birthDate || ''}"`,
      `"${a.age || ''}"`,
      `"${a.email || ''}"`,
      `"${a.contactNo || ''}"`,
      `"${(a.address || '').replace(/"/g, '""')}"`,
      `"${a.level || ''}"`,
      `"${a.program || ''}"`,
      `"${a.branch || ''}"`,
      `"${a.entryType || ''}"`,
      `"${a.voucherBeneficiary || ''}"`,
      `"${a.dateApplied || ''}"`,
      `"${a.status || ''}"`,
      `"${(a.notes || '').replace(/"/g, '""')}"`
    ]);

    const csvContent = "data:text/csv;charset=utf-8," + [headers.join(","), ...rows.map(e => e.join(","))].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    const branchTag = branchFilter !== "ALL" ? `_${branchFilter}` : '_AllCampuses';
    link.setAttribute("download", `DCSA_Enrollment_Applicants${branchTag}_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
};

// Initialize DB immediately and sync with Supabase
DCSA_DB.init();
