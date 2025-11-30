package com.webapp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.SecureRandom;

@WebServlet("/generate")
public class GeneratorServlet extends HttpServlet {
    
    private static final String LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    private static final String UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String DIGITS = "0123456789";
    private static final String SPECIAL = "!@#$%^&*";
    private static final SecureRandom random = new SecureRandom();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String type = request.getParameter("type");
        String ajax = request.getParameter("ajax");
        String result = "";
        
        if ("username".equals(type)) {
            result = generateUsername();
        } else if ("password".equals(type)) {
            int length = getIntParam(request, "length", 12);
            boolean useUpper = getBoolParam(request, "uppercase", true);
            boolean useLower = getBoolParam(request, "lowercase", true);
            boolean useDigits = getBoolParam(request, "digits", true);
            boolean useSpecial = getBoolParam(request, "special", true);
            result = generatePassword(length, useUpper, useLower, useDigits, useSpecial);
        }
        
        if ("true".equals(ajax)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"result\":\"" + escapeJson(result) + "\",\"type\":\"" + type + "\"}");
            out.flush();
        } else {
            request.setAttribute("result", result);
            request.setAttribute("type", type);
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
    
    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String value = request.getParameter(name);
        if (value != null) {
            try {
                return Integer.parseInt(value);
            } catch (NumberFormatException e) {
                return defaultValue;
            }
        }
        return defaultValue;
    }
    
    private boolean getBoolParam(HttpServletRequest request, String name, boolean defaultValue) {
        String value = request.getParameter(name);
        return value != null ? "true".equals(value) : defaultValue;
    }
    
    private String escapeJson(String str) {
        return str.replace("\\", "\\\\").replace("\"", "\\\"");
    }
    
    private String generateUsername() {
        String[] adjectives = {"Cool", "Fast", "Smart", "Bold", "Quick", "Brave", "Wise", "Grand"};
        String[] nouns = {"Tiger", "Eagle", "Dragon", "Wolf", "Falcon", "Lion", "Bear", "Fox"};
        return adjectives[random.nextInt(adjectives.length)] + 
               nouns[random.nextInt(nouns.length)] + 
               random.nextInt(1000);
    }
    
    private String generatePassword(int length, boolean useUpper, boolean useLower, 
                                    boolean useDigits, boolean useSpecial) {
        StringBuilder charset = new StringBuilder();
        if (useLower) charset.append(LOWERCASE);
        if (useUpper) charset.append(UPPERCASE);
        if (useDigits) charset.append(DIGITS);
        if (useSpecial) charset.append(SPECIAL);
        
        if (charset.length() == 0) charset.append(LOWERCASE);
        
        StringBuilder password = new StringBuilder(length);
        int ensuredChars = 0;
        
        if (useUpper && ensuredChars < length) {
            password.append(UPPERCASE.charAt(random.nextInt(UPPERCASE.length())));
            ensuredChars++;
        }
        if (useLower && ensuredChars < length) {
            password.append(LOWERCASE.charAt(random.nextInt(LOWERCASE.length())));
            ensuredChars++;
        }
        if (useDigits && ensuredChars < length) {
            password.append(DIGITS.charAt(random.nextInt(DIGITS.length())));
            ensuredChars++;
        }
        if (useSpecial && ensuredChars < length) {
            password.append(SPECIAL.charAt(random.nextInt(SPECIAL.length())));
            ensuredChars++;
        }
        
        for (int i = ensuredChars; i < length; i++) {
            password.append(charset.charAt(random.nextInt(charset.length())));
        }
        
        return shuffleString(password.toString());
    }
    
    private String shuffleString(String str) {
        char[] chars = str.toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        return new String(chars);
    }
}
