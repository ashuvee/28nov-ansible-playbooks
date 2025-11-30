<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Secure Generator</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif; background: #0a0e27; min-height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; color: #fff; }
        .container { max-width: 850px; width: 100%; text-align: center; }
        
        .logo { width: 80px; height: 80px; background: linear-gradient(135deg, #a78bfa 0%, #6366f1 100%); border-radius: 20px; margin: 0 auto 30px; display: flex; align-items: center; justify-content: center; }
        .logo svg { width: 40px; height: 40px; }
        
        h1 { font-size: 48px; font-weight: 700; margin-bottom: 10px; letter-spacing: -1px; }
        .subtitle { color: #9ca3af; font-size: 18px; margin-bottom: 50px; }
        
        .card { background: #1a1f3a; border: 1px solid #2d3550; border-radius: 24px; padding: 50px; }
        
        .generate-both-btn { width: 100%; background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%); color: white; border: none; padding: 18px; border-radius: 16px; font-size: 18px; font-weight: 600; cursor: pointer; margin-bottom: 40px; display: flex; align-items: center; justify-content: center; gap: 10px; transition: all 0.3s; }
        .generate-both-btn svg { width: 22px; height: 22px; flex-shrink: 0; }
        .generate-both-btn:hover { transform: translateY(-2px); box-shadow: 0 10px 30px rgba(139, 92, 246, 0.4); }
        .generate-both-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
        
        .field-section { margin-bottom: 35px; }
        .field-label { display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; color: #9ca3af; margin-bottom: 12px; text-align: left; }
        .field-label svg { width: 18px; height: 18px; }
        
        .field-container { display: flex; gap: 12px; align-items: stretch; }
        .field-input { flex: 1; background: #0f1419; border: 1px solid #2d3550; border-radius: 12px; padding: 18px 20px; color: #9ca3af; font-size: 16px; font-family: 'Courier New', monospace; text-align: left; }
        .field-input.generated { color: #fff; }
        
        .icon-btn { background: #374151; border: none; width: 56px; height: 56px; border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.3s; flex-shrink: 0; }
        .icon-btn:hover { background: #4b5563; transform: scale(1.05); }
        .icon-btn:active { transform: scale(0.95); }
        .icon-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .icon-btn svg { width: 20px; height: 20px; }
        
        .regenerate-btn { background: linear-gradient(135deg, #8b5cf6 0%, #6366f1 100%); }
        .regenerate-btn:hover { background: linear-gradient(135deg, #7c3aed 0%, #4f46e5 100%); }
        
        .password-regenerate-btn { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
        .password-regenerate-btn:hover { background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); }
        
        .options-toggle { background: transparent; border: none; color: #f97316; font-size: 14px; font-weight: 600; cursor: pointer; padding: 15px 0; display: flex; align-items: center; gap: 8px; margin-top: 20px; transition: all 0.3s; }
        .options-toggle:hover { color: #fb923c; }
        .options-toggle svg { width: 16px; height: 16px; transition: transform 0.3s; }
        .options-toggle.open svg { transform: rotate(90deg); }
        
        .options-panel { max-height: 0; overflow: hidden; transition: max-height 0.3s ease; }
        .options-panel.show { max-height: 400px; margin-top: 20px; }
        .options-content { background: #0f1419; border: 1px solid #2d3550; border-radius: 12px; padding: 25px; }
        
        .option-group { margin-bottom: 20px; text-align: left; }
        .option-group:last-child { margin-bottom: 0; }
        .option-label { font-size: 14px; font-weight: 600; color: #d1d5db; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; }
        .length-value { color: #3b82f6; font-size: 18px; }
        
        input[type="range"] { width: 100%; height: 6px; border-radius: 3px; background: #374151; outline: none; -webkit-appearance: none; }
        input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; width: 20px; height: 20px; border-radius: 50%; background: #3b82f6; cursor: pointer; }
        input[type="range"]::-moz-range-thumb { width: 20px; height: 20px; border-radius: 50%; background: #3b82f6; cursor: pointer; border: none; }
        
        .checkboxes { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
        .checkbox-item { display: flex; align-items: center; gap: 10px; }
        .checkbox-item input[type="checkbox"] { width: 20px; height: 20px; cursor: pointer; accent-color: #3b82f6; }
        .checkbox-item label { font-size: 14px; color: #9ca3af; cursor: pointer; }
        
        .toast { position: fixed; top: 30px; right: 30px; background: #10b981; color: white; padding: 16px 24px; border-radius: 12px; box-shadow: 0 10px 40px rgba(16, 185, 129, 0.3); display: none; align-items: center; gap: 12px; z-index: 1000; animation: slideIn 0.3s ease; }
        .toast.show { display: flex; }
        .toast svg { width: 24px; height: 24px; }
        
        @keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        
        @media (max-width: 768px) {
            h1 { font-size: 36px; }
            .card { padding: 30px 20px; }
            .field-container { flex-wrap: wrap; }
            .icon-btn { width: 48px; height: 48px; }
            .checkboxes { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
        </div>
        
        <h1>Secure Generator</h1>
        <p class="subtitle">Create strong credentials instantly</p>
        
        <div class="card">
            <button class="generate-both-btn" onclick="generateBoth()">
                <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                Generate Both
            </button>
            
            <div class="field-section">
                <div class="field-label">
                    <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    USERNAME
                </div>
                <div class="field-container">
                    <div class="field-input" id="usernameField">Click generate to create</div>
                    <button class="icon-btn regenerate-btn" onclick="generate('username')" title="Regenerate">
                        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                    </button>
                    <button class="icon-btn" onclick="copyToClipboard('username')" id="copyUsernameBtn" title="Copy" disabled>
                        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
                    </button>
                </div>
            </div>
            
            <div class="field-section">
                <div class="field-label">
                    <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
                    PASSWORD
                </div>
                <div class="field-container">
                    <div class="field-input" id="passwordField" data-password="">Click generate to create</div>
                    <button class="icon-btn" onclick="togglePasswordVisibility()" title="Show/Hide">
                        <svg id="eyeIcon" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                    </button>
                    <button class="icon-btn password-regenerate-btn" onclick="generate('password')" title="Regenerate">
                        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                    </button>
                    <button class="icon-btn" onclick="copyToClipboard('password')" id="copyPasswordBtn" title="Copy" disabled>
                        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
                    </button>
                </div>
            </div>
            
            <button class="options-toggle" onclick="toggleOptions()">
                <svg fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"/></svg>
                Password Options
            </button>
            
            <div class="options-panel" id="optionsPanel">
                <div class="options-content">
                    <div class="option-group">
                        <div class="option-label">
                            <span>Length</span>
                            <span class="length-value" id="lengthValue">12</span>
                        </div>
                        <input type="range" id="lengthSlider" min="8" max="32" value="12" oninput="updateLength()">
                    </div>
                    <div class="option-group">
                        <div class="option-label">Include Characters</div>
                        <div class="checkboxes">
                            <div class="checkbox-item">
                                <input type="checkbox" id="uppercase" checked>
                                <label for="uppercase">Uppercase (A-Z)</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="lowercase" checked>
                                <label for="lowercase">Lowercase (a-z)</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="digits" checked>
                                <label for="digits">Numbers (0-9)</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="special" checked>
                                <label for="special">Symbols (!@#$)</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="toast" id="toast">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></svg>
        <span id="toastMessage">Copied to clipboard!</span>
    </div>
    
    <script>
        let passwordVisible = false;
        let usernameGenerated = false;
        let passwordGenerated = false;
        
        function updateLength() {
            document.getElementById('lengthValue').textContent = document.getElementById('lengthSlider').value;
        }
        
        function toggleOptions() {
            const panel = document.getElementById('optionsPanel');
            const toggle = document.querySelector('.options-toggle');
            panel.classList.toggle('show');
            toggle.classList.toggle('open');
        }
        
        function togglePasswordVisibility() {
            const field = document.getElementById('passwordField');
            const password = field.dataset.password;
            if (!password) return;
            
            passwordVisible = !passwordVisible;
            field.textContent = passwordVisible ? password : '•'.repeat(password.length);
            
            const eyeIcon = document.getElementById('eyeIcon');
            if (passwordVisible) {
                eyeIcon.innerHTML = '<path d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>';
            } else {
                eyeIcon.innerHTML = '<path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>';
            }
        }
        
        function generateBoth() {
            generate('username');
            setTimeout(() => generate('password'), 200);
        }
        
        function generate(type) {
            const buttons = document.querySelectorAll('button');
            buttons.forEach(btn => btn.disabled = true);
            
            let params = 'type=' + type + '&ajax=true';
            
            if (type === 'password') {
                const length = document.getElementById('lengthSlider').value;
                const uppercase = document.getElementById('uppercase').checked;
                const lowercase = document.getElementById('lowercase').checked;
                const digits = document.getElementById('digits').checked;
                const special = document.getElementById('special').checked;
                
                params += '&length=' + length;
                params += '&uppercase=' + uppercase;
                params += '&lowercase=' + lowercase;
                params += '&digits=' + digits;
                params += '&special=' + special;
            }
            
            fetch('generate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (type === 'username') {
                    document.getElementById('usernameField').textContent = data.result;
                    document.getElementById('usernameField').classList.add('generated');
                    document.getElementById('copyUsernameBtn').disabled = false;
                    usernameGenerated = true;
                } else {
                    const field = document.getElementById('passwordField');
                    field.dataset.password = data.result;
                    field.textContent = '•'.repeat(data.result.length);
                    field.classList.add('generated');
                    document.getElementById('copyPasswordBtn').disabled = false;
                    passwordVisible = false;
                    passwordGenerated = true;
                }
                showToast('Generated successfully!');
                buttons.forEach(btn => btn.disabled = false);
            })
            .catch(error => {
                showToast('Error generating. Please try again.');
                buttons.forEach(btn => btn.disabled = false);
            });
        }
        
        function copyToClipboard(type) {
            let text = '';
            if (type === 'username') {
                text = document.getElementById('usernameField').textContent;
            } else {
                text = document.getElementById('passwordField').dataset.password;
            }
            
            navigator.clipboard.writeText(text).then(() => {
                showToast('Copied to clipboard!');
            }).catch(() => {
                showToast('Failed to copy');
            });
        }
        
        function showToast(message) {
            const toast = document.getElementById('toast');
            const toastMessage = document.getElementById('toastMessage');
            toastMessage.textContent = message;
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
            }, 3000);
        }
    </script>
</body>
</html>
