# CloudKit Troubleshooting Guide

## Issue: Submissions Not Appearing in Admin View

### Quick Checks:

1. **Verify iCloud is Signed In (on iPhone)**
   - Settings → [Your Name] → iCloud
   - Make sure you're signed in with an Apple ID
   - iCloud Drive should be enabled

2. **Check CloudKit Dashboard for Records**
   - Go to: https://icloud.developer.apple.com/dashboard
   - Select container: `iCloud.ChapterFinder`
   - Click on **Data** → **Records**
   - Switch to **Production** environment (top right)
   - Look for `ChapterUpdateSubmission` records
   - **If you see records here but not in the app**, it's a fetch issue
   - **If you don't see records**, submission didn't save

3. **Verify Environment Settings**
   - In Xcode: Product → Scheme → Edit Scheme
   - Look at "Run" section
   - Make sure you're using **Production** CloudKit environment
   - (Usually defaults to automatic which uses Production for App Store builds)

4. **Check App's iCloud Status**
   - On iPhone: Settings → [Your App Name] → iCloud
   - Make sure iCloud is enabled for the app

### Common Issues & Solutions:

#### Issue A: Records in CloudKit Dashboard but Not in App
**Solution**: Add debug logging to see the fetch response

#### Issue B: No Records in CloudKit Dashboard
**Solution**: Submission failed - check:
- iCloud signed in on device
- Network connection
- CloudKit container identifier matches

#### Issue C: "Failed to submit update" Error
**Solution**: 
- Check iCloud account status
- Verify CloudKit entitlements are correct
- Make sure app is signed with correct team

### Debug Steps:

1. **Add Console Logging**
   Open `SubmissionManager.swift` and add print statements:
   
   ```swift
   func submitUpdate(_ submission: ChapterUpdateSubmission) async throws {
       print("🔵 Attempting to save submission...")
       isLoading = true
       defer { isLoading = false }
       
       let record = submission.toRecord()
       print("🔵 Record created: \(record)")
       
       do {
           let savedRecord = try await publicDatabase.save(record)
           print("✅ Successfully saved to CloudKit: \(savedRecord.recordID)")
           await MainActor.run {
               errorMessage = nil
           }
       } catch {
           print("❌ CloudKit save error: \(error)")
           await MainActor.run {
               errorMessage = "Failed to submit update: \(error.localizedDescription)"
           }
           throw error
       }
   }
   
   func fetchAllSubmissions() async {
       print("🔵 Fetching submissions...")
       isLoading = true
       defer { isLoading = false }
       
       let query = CKQuery(recordType: "ChapterUpdateSubmission", predicate: NSPredicate(value: true))
       query.sortDescriptors = [NSSortDescriptor(key: "submittedAt", ascending: false)]
       
       do {
           let results = try await publicDatabase.records(matching: query)
           print("🔵 Fetch results count: \(results.matchResults.count)")
           
           let fetchedSubmissions = results.matchResults.compactMap { id, result -> ChapterUpdateSubmission? in
               guard case .success(let record) = result else {
                   print("❌ Failed to get record for \(id)")
                   return nil
               }
               print("✅ Got record: \(record.recordID)")
               return ChapterUpdateSubmission.fromRecord(record)
           }
           
           print("✅ Parsed \(fetchedSubmissions.count) submissions")
           await MainActor.run {
               self.submissions = fetchedSubmissions
               self.errorMessage = nil
           }
       } catch {
           print("❌ CloudKit fetch error: \(error)")
           await MainActor.run {
               self.errorMessage = "Failed to fetch submissions: \(error.localizedDescription)"
           }
       }
   }
   ```

2. **Test Submission Flow**
   - Run app from Xcode with device connected
   - Watch Console output when submitting
   - Watch Console output when viewing admin page
   - Share console logs if issues persist

3. **Manual CloudKit Check**
   - Go to CloudKit Dashboard
   - Data → Records
   - Select Record Type: `ChapterUpdateSubmission`
   - **Make sure you're in Production environment**
   - You should see your test submission

### Expected Console Output (Successful):

**When Submitting:**
```
🔵 Attempting to save submission...
🔵 Record created: <CKRecord ID>
✅ Successfully saved to CloudKit: <Record ID>
```

**When Fetching (Admin View):**
```
🔵 Fetching submissions...
🔵 Fetch results count: 1
✅ Got record: <Record ID>
✅ Parsed 1 submissions
```

### Still Not Working?

1. **Delete and reinstall the app** (sometimes CloudKit permissions get cached)
2. **Sign out and back into iCloud** on the device
3. **Check Xcode console** for specific error messages
4. **Verify CloudKit schema** in Production matches Development

---

## Quick Test:

Try this on your iPhone:
1. Open the app
2. Go to Contact tab
3. Fill out the form
4. Submit
5. **Immediately take a screenshot** if you see an error
6. Then check CloudKit Dashboard → Data → Records → Production
7. Look for your submission there

If you see it in the dashboard but not in the app, it's definitely a fetch issue and we need to debug the query.
